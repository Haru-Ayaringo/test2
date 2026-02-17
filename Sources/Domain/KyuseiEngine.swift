import Foundation

protocol KyuseiEngine {
    func generateBoard(
        type: BoardType,
        date: Date,
        location: AppLocation,
        profile: Profile?
    ) -> Board
}
