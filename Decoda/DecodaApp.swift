import SwiftUI

@main
struct DecodaApp: App {

    @StateObject private var appearanceSettings = AppearanceSettings()
    @StateObject private var previewSettings = PreviewSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appearanceSettings)
                .environmentObject(previewSettings)
                .preferredColorScheme(
                    appearanceSettings.appearance.colorScheme
                )
        }

        Settings {
            SettingsView()
                .environmentObject(appearanceSettings)
                .environmentObject(previewSettings)
        }
    }
}
