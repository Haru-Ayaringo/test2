import Foundation

enum BoardType: String, CaseIterable, Codable, Identifiable {
    case year
    case month
    case day

    var id: String { rawValue }

    var title: String {
        switch self {
        case .year:
            return "年盤"
        case .month:
            return "月盤"
        case .day:
            return "日盤"
        }
    }
}
