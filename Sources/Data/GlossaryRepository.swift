import Foundation
import Combine

@MainActor
final class GlossaryRepository: ObservableObject {
    @Published private(set) var allTerms: [GlossaryTerm] = []

    init() {
        allTerms = loadGlossary()
    }

    func term(for shortLabel: String) -> GlossaryTerm? {
        let normalized = normalize(shortLabel)
        return allTerms.first { normalize($0.shortLabel) == normalized }
    }

    private func loadGlossary() -> [GlossaryTerm] {
        let bundles = [Bundle.main, Bundle(for: BundleToken.self)]

        for bundle in bundles {
            if let url = bundle.url(forResource: "glossary", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([GlossaryTerm].self, from: data) {
                return decoded
            }
        }

        return []
    }

    private func normalize(_ label: String) -> String {
        label.replacingOccurrences(of: "（", with: "(")
            .replacingOccurrences(of: "）", with: ")")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private final class BundleToken {}
