import SwiftUI

/// Three pages. Continue, Next, then START. Skip leaves a cold galley.
struct OnboardingView: View {
    @ObservedObject var store: GalleyStore
    @State private var page = 0

    private let pages: [(String, String, String)] = [
        ("glw_Onboarding1", "Two dishes, one line.", "Save a meal, then fill the open place."),
        ("glw_Onboarding2", "Follow the lit step.", "Mark it done. Move to the other dish when it needs you."),
        ("glw_Onboarding3", "Finish the night.", "When both dishes are done, the pair stays on this device.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: WeaveSpace.steps(3)) {
            HStack {
                Spacer()
                Button("Skip") { finish() }
                    .buttonStyle(WeaveQuietStyle())
            }
            Image(pages[page].0)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: WeaveSpace.steps(28))
                .clipped()
                .accessibilityHidden(true)
            Text(pages[page].1)
                .font(WeaveType.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(pages[page].2)
                .font(WeaveType.body)
                .foregroundStyle(DesignTokens.muted)
            Spacer()
            Button(page == 0 ? "Continue" : page == 1 ? "Next" : "START") {
                if page < 2 {
                    page += 1
                } else {
                    finish()
                }
            }
            .buttonStyle(WeaveVerbStyle())
        }
        .padding(WeaveSpace.steps(3))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(DesignTokens.bg.ignoresSafeArea())
    }

    private func finish() {
        store.markOnboardingComplete()
    }
}
