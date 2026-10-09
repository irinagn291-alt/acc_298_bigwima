import Foundation

/// One client for both TheMealDB calls: search and lookup. Page size is 8.
actor MealLookup {
    static let userAgent = "Galleyweave/1.0 (iOS; +https://galleyweave-weave.pro)"
    static let pageSize = 8

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = MealLookup.makeSession()) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    /// Empty text does not hit the network. `page` is 1-based over the meals array.
    func search(query: String, page: Int) async throws -> [Recipe] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return [] }
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(encoded)")
        else {
            throw MealLookupError.malformed
        }
        let meals = try await fetchMeals(url)
        let start = max(page - 1, 0) * Self.pageSize
        guard start < meals.count else { return [] }
        let end = min(start + Self.pageSize, meals.count)
        return meals[start..<end].map(MealMapping.recipe(from:))
    }

    func lookup(id: String) async throws -> Recipe {
        guard let encoded = id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(encoded)")
        else {
            throw MealLookupError.malformed
        }
        let meals = try await fetchMeals(url)
        guard let first = meals.first else { throw MealLookupError.notFound }
        return MealMapping.recipe(from: first)
    }

    private func fetchMeals(_ url: URL) async throws -> [MealDTO] {
        let data = try await load(url, allowRetry: true)
        let envelope: MealEnvelope
        do {
            envelope = try decoder.decode(MealEnvelope.self, from: data)
        } catch {
            throw MealLookupError.malformed
        }
        return envelope.meals ?? []
    }

    private func load(_ url: URL, allowRetry: Bool) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        do {
            try Task.checkCancellation()
            let (data, response) = try await session.data(for: request)
            try Task.checkCancellation()
            guard let http = response as? HTTPURLResponse else {
                throw MealLookupError.transport
            }
            if http.statusCode == 404 {
                throw MealLookupError.notFound
            }
            if (200..<300).contains(http.statusCode) {
                return data
            }
            if allowRetry && Self.isTransientStatus(http.statusCode) {
                return try await load(url, allowRetry: false)
            }
            throw MealLookupError.transport
        } catch let error as MealLookupError {
            throw error
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as URLError where allowRetry && Self.isTransient(error) {
            return try await load(url, allowRetry: false)
        } catch {
            throw MealLookupError.transport
        }
    }

    private static func isTransient(_ error: URLError) -> Bool {
        switch error.code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost, .dnsLookupFailed:
            return true
        default:
            return false
        }
    }

    private static func isTransientStatus(_ code: Int) -> Bool {
        code == 408 || code == 429 || (500...599).contains(code)
    }

    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }
}

enum MealLookupError: Error, Equatable {
    case notFound
    case transport
    case malformed
}

struct MealEnvelope: Decodable, Sendable {
    var meals: [MealDTO]?
}

/// Mirrors a TheMealDB meal object. Domain recipes are mapped afterwards.
struct MealDTO: Decodable, Sendable {
    var idMeal: String
    var strMeal: String
    var strInstructions: String?
    var strMealThumb: String?
    var ingredients: [(name: String, measure: String)]

    private struct DynamicKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        func key(_ name: String) -> DynamicKey? { DynamicKey(stringValue: name) }
        guard let idKey = key("idMeal"), let nameKey = key("strMeal") else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Meal keys missing."))
        }
        idMeal = try container.decode(String.self, forKey: idKey)
        strMeal = try container.decode(String.self, forKey: nameKey)
        if let instructionsKey = key("strInstructions") {
            strInstructions = try container.decodeIfPresent(String.self, forKey: instructionsKey)
        } else {
            strInstructions = nil
        }
        if let thumbKey = key("strMealThumb") {
            strMealThumb = try container.decodeIfPresent(String.self, forKey: thumbKey)
        } else {
            strMealThumb = nil
        }
        var pairs: [(String, String)] = []
        for index in 1...20 {
            guard let ingredientKey = key("strIngredient\(index)") else { continue }
            let name = try container.decodeIfPresent(String.self, forKey: ingredientKey)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if name.isEmpty { continue }
            let measure: String
            if let measureKey = key("strMeasure\(index)") {
                measure = try container.decodeIfPresent(String.self, forKey: measureKey)?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            } else {
                measure = ""
            }
            pairs.append((name, measure))
        }
        ingredients = pairs
    }
}

enum MealMapping {
    static func recipe(from meal: MealDTO) -> Recipe {
        Recipe(
            id: UUID(),
            catalogID: meal.idMeal,
            title: meal.strMeal,
            ingredients: meal.ingredients.map { pair in
                IngredientLine(id: UUID(), name: pair.name, measure: pair.measure)
            },
            steps: numberedSteps(from: meal.strInstructions),
            thumbnailURL: meal.strMealThumb
        )
    }

    static func numberedSteps(from instructions: String?) -> [NumberedStep] {
        let raw = (instructions ?? "").replacingOccurrences(of: "\r\n", with: "\n")
        var lines = raw.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        if lines.count <= 1, let only = lines.first {
            let sentences = only.split(separator: ".").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            if sentences.count > 1 {
                lines = sentences
            }
        }
        return lines.enumerated().map { offset, line in
            NumberedStep(id: UUID(), number: offset + 1, text: line, seconds: seconds(in: line))
        }
    }

    /// A minute or hour phrase becomes seconds. Every other step stays at zero.
    static func seconds(in text: String) -> Int {
        let pattern = #"(\d+)\s*(hours?|hrs?|minutes?|mins?)"#
        guard let expression = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return 0
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        var total = 0
        for match in expression.matches(in: text, range: range) {
            guard match.numberOfRanges > 2,
                  let amountRange = Range(match.range(at: 1), in: text),
                  let unitRange = Range(match.range(at: 2), in: text),
                  let amount = Int(text[amountRange])
            else { continue }
            let unit = text[unitRange].lowercased()
            if unit.hasPrefix("h") {
                total += amount * 3600
            } else {
                total += amount * 60
            }
        }
        return total
    }
}
