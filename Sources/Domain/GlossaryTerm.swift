import Foundation

struct GlossaryTerm: Identifiable, Codable, Equatable {
    let key: String
    let shortLabel: String
    let title: String
    let description: String

    var id: String { key }
}
