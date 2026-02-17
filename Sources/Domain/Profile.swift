import Foundation

struct Profile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var birthDate: Date
    let createdAt: Date

    init(id: UUID = UUID(), name: String = "", birthDate: Date, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.createdAt = createdAt
    }
}
