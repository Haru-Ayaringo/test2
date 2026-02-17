import Foundation

struct DisplaySettings: Codable, Equatable {
    enum MapStyle: String, CaseIterable, Codable, Identifiable {
        case standard
        case hybrid
        case imagery

        var id: String { rawValue }

        var title: String {
            switch self {
            case .standard:
                return "標準"
            case .hybrid:
                return "ハイブリッド"
            case .imagery:
                return "航空写真"
            }
        }
    }

    var overlayOpacity: Double
    var mapStyle: MapStyle

    static let `default` = DisplaySettings(
        overlayOpacity: 0.6,
        mapStyle: .standard
    )
}
