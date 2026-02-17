import SwiftUI

struct BoardCanvasView: View {
    let board: Board
    @Binding var selectedCellPosition: BoardPosition

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(BoardPosition.allCases) { position in
                let cell = board.cell(at: position) ?? board.center
                Button {
                    selectedCellPosition = position
                } label: {
                    VStack(spacing: 6) {
                        Text(position.shortLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text("\(cell.starNumber)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .monospacedDigit()

                        Text(cell.markers.map(\.shortLabel).joined(separator: " "))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: 88)
                    .background(selectedCellPosition == position ? Color.accentColor.opacity(0.18) : Color.clear)
                    .overlay {
                        Rectangle()
                            .stroke(
                                selectedCellPosition == position ? Color.accentColor : Color.secondary.opacity(0.35),
                                lineWidth: selectedCellPosition == position ? 3 : 1
                            )
                    }
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityLabel(for: cell))
                .accessibilityHint("ダブルタップでこのセルを選択")
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
        }
    }

    private func accessibilityLabel(for cell: BoardCell) -> String {
        let markerText = cell.markers.isEmpty
            ? "マーカーなし"
            : cell.markers.map(\.title).joined(separator: "、")
        return "方位 \(cell.position.shortLabel)、星 \(cell.starNumber)、\(markerText)"
    }
}

#Preview {
    BoardCanvasView(
        board: StubKyuseiEngine().makeBoard(
            profile: Profile(name: "Preview", birthDate: .now),
            date: .now,
            type: .day
        ),
        selectedCellPosition: .constant(.center)
    )
    .padding()
}
