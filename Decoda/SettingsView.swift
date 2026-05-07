import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var appearanceSettings: AppearanceSettings
    @EnvironmentObject private var previewSettings: PreviewSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {

            // Header
            HStack(spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(6)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Decoda Settings")
                        .font(.headline)

                    Text("Customize appearance and decoding behavior")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Appearance
            VStack(alignment: .leading, spacing: 12) {
                Label("Appearance", systemImage: "circle.lefthalf.filled")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Picker("Appearance", selection: $appearanceSettings.appearance) {
                    ForEach(AppAppearance.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            Divider()

            // Preview behavior
            VStack(alignment: .leading, spacing: 12) {
                Label("Preview", systemImage: "doc.text.magnifyingglass")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Toggle(
                    "Show preview after decoding",
                    isOn: $previewSettings.showPreviewAfterDecode
                )

                Toggle(
                    "Automatically open XML file",
                    isOn: $previewSettings.autoOpenXML
                )
            }

            // Preview mode
            VStack(alignment: .leading, spacing: 12) {
                Label("Preview Mode", systemImage: "rectangle.split.vertical")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Picker("Preview Mode", selection: $previewSettings.previewMode) {
                    ForEach(PreviewMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Spacer()

            // Footer
            VStack(spacing: 6) {
                Text("Decoda")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text("All files are processed locally.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .frame(width: 380, height: 340)
    }
}
