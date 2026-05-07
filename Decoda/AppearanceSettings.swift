import SwiftUI
import Combine

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@MainActor
final class AppearanceSettings: ObservableObject {

    @AppStorage("appAppearance")
    private var storedAppearance: String = AppAppearance.system.rawValue

    var appearance: AppAppearance {
        get {
            AppAppearance(rawValue: storedAppearance) ?? .system
        }
        set {
            storedAppearance = newValue.rawValue
            objectWillChange.send()
        }
    }
}
