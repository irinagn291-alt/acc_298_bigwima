import SwiftUI

/// Catalog credit, contact, replay, and a confirmed reset.
struct SettingsView: View {
    @ObservedObject var store: GalleyStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button("TheMealDB") {
                        if let url = URL(string: "https://www.themealdb.com") {
                            openURL(url)
                        }
                    }
                    Button("Contact") {
                        if let url = URL(string: "https://galleyweave-weave.pro/contact-us") {
                            openURL(url)
                        }
                    }
                }
                Section {
                    Button("Replay onboarding") {
                        store.replayOnboarding()
                        dismiss()
                    }
                }
                Section {
                    Button("Reset") { confirmReset = true }
                        .buttonStyle(WeaveDangerStyle())
                } footer: {
                    Text("Meals from TheMealDB stay credited. Everything else stays on this device.")
                        .font(WeaveType.caption)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .confirmationDialog(
                "Reset tonight?",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    Task { await store.resetAllData() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Saved recipes and served nights on this device will be removed.")
            }
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(WeaveRadius.plate)
    }
}
