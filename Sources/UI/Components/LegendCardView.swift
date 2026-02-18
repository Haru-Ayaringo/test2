import SwiftUI

struct LegendCardView: View {
    let markers: [Marker]
    var isCollapsible: Bool = false

    @StateObject private var glossaryRepository = GlossaryRepository()
    @State private var isExpanded = true
    @State private var selectedTerm: GlossaryTerm?
    @State private var isShowingGlossaryList = false

    private var uniqueMarkers: [Marker] {
        Array(Set(markers)).sorted { $0.rawValue < $1.rawValue }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("凡例")
                    .font(.headline)
                Spacer()
                Button {
                    isShowingGlossaryList = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("用語解説一覧")
            }

            if isCollapsible {
                DisclosureGroup("略号を表示", isExpanded: $isExpanded) {
                    markerRows
                        .padding(.top, 4)
                }
            } else {
                markerRows
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        .sheet(item: $selectedTerm) { term in
            GlossaryTermSheet(term: term)
        }
        .sheet(isPresented: $isShowingGlossaryList) {
            NavigationStack {
                GlossaryListView()
            }
        }
    }

    private var markerRows: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(uniqueMarkers, id: \.rawValue) { marker in
                Button {
                    if let term = glossaryRepository.term(for: marker.shortLabel) {
                        selectedTerm = term
                    }
                } label: {
                    HStack {
                        Text(marker.shortLabel)
                            .font(.caption.bold())
                            .frame(width: 34, height: 22)
                            .background(Color.accentColor.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                        Text(marker.title)
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    LegendCardView(markers: Marker.allCases)
        .padding()
}
