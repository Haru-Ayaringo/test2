import SwiftUI

struct GlossaryListView: View {
    @StateObject private var glossaryRepository = GlossaryRepository()
    @State private var searchText = ""
    @State private var selectedTerm: GlossaryTerm?

    private var filteredTerms: [GlossaryTerm] {
        guard !searchText.isEmpty else { return glossaryRepository.allTerms }
        return glossaryRepository.allTerms.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.shortLabel.localizedCaseInsensitiveContains(searchText)
                || $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            ForEach(filteredTerms) { term in
                Button {
                    selectedTerm = term
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(term.shortLabel) \(term.title)")
                            .foregroundStyle(.primary)
                        Text(term.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
        }
        .navigationTitle("用語解説")
        .searchable(text: $searchText, prompt: "略号や用語名で検索")
        .sheet(item: $selectedTerm) { term in
            GlossaryTermSheet(term: term)
        }
    }
}

#Preview {
    NavigationStack {
        GlossaryListView()
    }
}
