import SwiftUI
import Combine

enum PreviewMode: String, CaseIterable, Identifiable {
    case summary
    case rawXML
    case both

    var id: String { rawValue }

    var title: String {
        switch self {
        case .summary:
            return "Summary"
        case .rawXML:
            return "Raw XML"
        case .both:
            return "Summary + XML"
        }
    }
}

@MainActor
final class PreviewSettings: ObservableObject {

    @AppStorage("showPreviewAfterDecode")
    var showPreviewAfterDecode: Bool = true

    @AppStorage("autoOpenXML")
    var autoOpenXML: Bool = false

    @AppStorage("previewMode")
    private var storedPreviewMode: String = PreviewMode.summary.rawValue

    var previewMode: PreviewMode {
        get {
            PreviewMode(rawValue: storedPreviewMode) ?? .summary
        }
        set {
            storedPreviewMode = newValue.rawValue
            objectWillChange.send()
        }
    }
}
