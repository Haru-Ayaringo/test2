import Foundation

struct StubKyuseiEngine: KyuseiEngine {
    func generateBoard(type: BoardType, date: Date, location: AppLocation, profile: Profile?) -> Board {
        let positions = BoardPosition.allCases
        let base = baseIndex(type: type, date: date)

        let cells: [BoardCell] = positions.enumerated().map { index, position in
            let starNumber = ((base + index) % 9) + 1
            return BoardCell(
                position: position,
                starNumber: starNumber,
                labels: [position.shortLabel, type.title],
                markers: markers(for: starNumber)
            )
        }

        let center = cells.first(where: { $0.position == .center }) ?? cells[4]
        return Board(type: type, cells: cells, center: center, generatedAt: date)
    }

    private func baseIndex(type: BoardType, date: Date) -> Int {
        let day = Calendar.current.component(.day, from: date)
        switch type {
        case .year:
            return day % 9
        case .month:
            return (day + 2) % 9
        case .day:
            return (day + 4) % 9
        }
    }

    private func markers(for star: Int) -> [Marker] {
        switch star {
        case 1, 6, 8:
            return [.good]
        case 5:
            return [.go, .ha]
        case 2:
            return [.teki]
        case 3:
            return [.an]
        case 4:
            return [.hon]
        default:
            return []
        }
    }
}
