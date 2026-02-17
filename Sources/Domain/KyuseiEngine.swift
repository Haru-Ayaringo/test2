import Foundation

protocol KyuseiEngine {
    func makeBoard(profile: Profile, date: Date, type: BoardType) -> Board
}
