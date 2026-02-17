import SwiftUI

struct BoardView: View {
    @EnvironmentObject private var store: AppStore

    @State private var selectedCellPosition: BoardPosition = .center
    private let engine: KyuseiEngine = StubKyuseiEngine()

    private var board: Board {
        engine.generateBoard(
            type: store.selectedBoardType,
            date: store.selectedDate,
            location: store.selectedLocation,
            profile: store.selectedProfile
        )
    }

    private var selectedCell: BoardCell {
        board.cell(at: selectedCellPosition) ?? board.center
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    DateBarView()
                    ProfilePickerButton()

                    Picker("盤種", selection: $store.selectedBoardType) {
                        ForEach(BoardType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    BoardCanvasView(board: board, selectedCellPosition: $selectedCellPosition)

                    detailCard
                    legendCard
                }
                .padding()
            }
            .navigationTitle("Board")
            .onChange(of: store.selectedBoardType) { _ in
                selectedCellPosition = .center
            }
        }
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("選択セル詳細")
                .font(.headline)
            Text("方位: \(selectedCell.position.shortLabel)")
            Text("星: \(selectedCell.starNumber)")
            Text("ラベル: \(selectedCell.labels.joined(separator: " / "))")
            Text("マーカー: \(selectedCell.markers.isEmpty ? "なし" : selectedCell.markers.map(\.title).joined(separator: "、"))")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private var legendCard: some View {
        LegendCardView(markers: Marker.allCases)
    }
}

#Preview {
    BoardView()
        .environmentObject(AppStore())
}
