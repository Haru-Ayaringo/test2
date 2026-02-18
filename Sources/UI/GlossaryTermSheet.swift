import SwiftUI

struct GlossaryTermSheet: View {
    let term: GlossaryTerm

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(term.shortLabel)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.2), in: Capsule())

                    Text(term.title)
                        .font(.title3.bold())

                    Text(term.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle("用語解説")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    GlossaryTermSheet(
        term: GlossaryTerm(
            key: "gohousatsu",
            shortLabel: "(五)",
            title: "五黄殺",
            description: "ダミー説明"
        )
    )
}
