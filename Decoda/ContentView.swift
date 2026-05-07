import SwiftUI
import UniformTypeIdentifiers
import AppKit

// MARK: - Conversion State

enum ConversionState: Equatable {
    case idle
    case processing
    case success(String)
    case error(String)
}

// MARK: - App Banner

struct AppBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 44, height: 44)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text("Decoda")
                    .font(.system(size: 28, weight: .semibold))

                Text("Decode and inspect configuration profiles")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

// MARK: - Drop Card

struct DropCard: View {
    let fileName: String?
    let isTargeted: Bool
    let onPick: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.badge.arrow.up")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)

            Text(fileName ?? "Drop a .mobileconfig file")
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.middle)

            Text("or click to browse")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 130)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isTargeted ? Color.accentColor : .secondary.opacity(0.4),
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
        )
        .animation(.spring(response: 0.25), value: isTargeted)
        .onTapGesture(perform: onPick)
    }
}

// MARK: - Content View

struct ContentView: View {

    @EnvironmentObject private var previewSettings: PreviewSettings

    @State private var inputFile: URL?
    @State private var conversionState: ConversionState = .idle
    @State private var isDragTargeted = false

    @State private var xmlText: String = ""
    @State private var showPreview = false

    @State private var searchText: String = ""

    var body: some View {
        HStack(spacing: 0) {

            // LEFT PANE
            VStack(spacing: 20) {

                AppBanner()

                DropCard(
                    fileName: inputFile?.lastPathComponent,
                    isTargeted: isDragTargeted,
                    onPick: pickInputFile
                )
                .padding(.horizontal)
                .onDrop(
                    of: [.fileURL],
                    isTargeted: $isDragTargeted,
                    perform: handleDrop
                )

                Text("Files are processed locally. Nothing is uploaded.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if inputFile != nil {
                    Button(action: convert) {
                        Label("Decode to XML", systemImage: "bolt.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                feedbackView

                // ✅ Bottom‑left contextual info
                if let file = inputFile {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current file")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(file.lastPathComponent)
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        if let size = fileSize(file) {
                            Text("~\(size)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 12)
                }

                Spacer()
            }
            .frame(minWidth: 420)

            // RIGHT PANE
            if showPreview,
               previewSettings.showPreviewAfterDecode,
               previewSettings.previewMode != .summary {

                Divider()

                previewPane
                    .frame(minWidth: 420)
                    .padding(.horizontal, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .frame(minWidth: 860, minHeight: 520)
    }

    // MARK: - Feedback View

    @ViewBuilder
    private var feedbackView: some View {
        switch conversionState {
        case .idle:
            EmptyView()

        case .processing:
            HStack {
                ProgressView()
                Text("Decoding…")
            }

        case .success(let message):
            Label(message, systemImage: "checkmark.circle.fill")
                .foregroundColor(.green)

        case .error(let message):
            Label(message, systemImage: "xmark.octagon.fill")
                .foregroundColor(.red)
        }
    }

    // MARK: - Preview Pane

    private var previewPane: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text("Raw XML")
                    .font(.headline)

                Spacer()

                Button {
                    copyXMLToClipboard()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .buttonStyle(.borderless)
            }

            TextField("Search XML", text: $searchText)
                .textFieldStyle(.roundedBorder)

            Divider()

            ScrollView {
                TextEditor(text: .constant(filteredXML))
                    .font(.system(.body, design: .monospaced))
                    .disabled(true)
            }
        }
        .padding()
    }

    // MARK: - Drag & Drop

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(
                    forTypeIdentifier: UTType.fileURL.identifier,
                    options: nil
                ) { item, _ in
                    guard
                        let data = item as? Data,
                        let url = URL(dataRepresentation: data, relativeTo: nil),
                        url.pathExtension == "mobileconfig"
                    else { return }

                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        inputFile = url
                        conversionState = .idle
                        showPreview = false
                        searchText = ""
                    }
                }
                return true
            }
        }
        return false
    }

    // MARK: - File Picker

    private func pickInputFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            UTType(filenameExtension: "mobileconfig")!
        ]

        if panel.runModal() == .OK {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                inputFile = panel.url
                conversionState = .idle
                showPreview = false
                searchText = ""
            }
        }
    }

    // MARK: - Conversion

    @MainActor
    private func convert() {
        guard let input = inputFile else { return }

        DispatchQueue.main.async {
            guard let window = NSApp.keyWindow else { return }

            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.xml]
            savePanel.nameFieldStringValue =
                input.deletingPathExtension().lastPathComponent + ".xml"

            savePanel.beginSheetModal(for: window) { response in
                guard response == .OK,
                      let outputURL = savePanel.url else { return }

                conversionState = .processing

                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try ConversionService.convert(input: input, output: outputURL)

                        let xml = try String(contentsOf: outputURL, encoding: .utf8)

                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            xmlText = xml
                            searchText = ""
                            showPreview = true
                            conversionState =
                                .success("Saved as \(outputURL.lastPathComponent)")

                            if previewSettings.autoOpenXML {
                                NSWorkspace.shared.open(outputURL)
                            }
                        }
                    } catch {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            conversionState = .error(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var filteredXML: String {
        guard !searchText.isEmpty else { return xmlText }
        return xmlText
            .split(separator: "\n")
            .filter { $0.localizedCaseInsensitiveContains(searchText) }
            .joined(separator: "\n")
    }

    private func copyXMLToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(xmlText, forType: .string)
    }

    private func fileSize(_ url: URL) -> String? {
        guard
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
            let bytes = attributes[.size] as? Int
        else { return nil }

        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
