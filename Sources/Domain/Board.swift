import Foundation

struct BoardCell: Identifiable, Codable, Equatable {
    let position: BoardPosition
    var starNumber: Int
    var labels: [String]
    var markers: [Marker]

    var id: BoardPosition { position }
}

struct Board: Codable, Equatable {
    var type: BoardType
    var cells: [BoardCell]
    var center: BoardCell
    var generatedAt: Date

    func cell(at position: BoardPosition) -> BoardCell? {
        cells.first(where: { $0.position == position })
    }
}

enum Marker: String, CaseIterable, Codable, Hashable {
    case good
    case go
    case an
    case hon
    case teki
    case ha

    var shortLabel: String {
        switch self {
        case .good: return "(吉)"
        case .go: return "(五)"
        case .an: return "(暗)"
        case .hon: return "(本)"
        case .teki: return "(的)"
        case .ha: return "(破)"
        }
    }

    var title: String {
        switch self {
        case .good: return "吉方"
        case .go: return "五黄殺"
        case .an: return "暗剣殺"
        case .hon: return "本命殺"
        case .teki: return "本命的殺"
        case .ha: return "歳破"
        }
    }
}

enum BoardPosition: String, CaseIterable, Codable, Identifiable, Hashable {
    case northWest
    case north
    case northEast
    case west
    case center
    case east
    case southWest
    case south
    case southEast

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .northWest: return "NW"
        case .north: return "N"
        case .northEast: return "NE"
        case .west: return "W"
        case .center: return "C"
        case .east: return "E"
        case .southWest: return "SW"
        case .south: return "S"
        case .southEast: return "SE"
        }
    }
}
