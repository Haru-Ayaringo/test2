import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct BoardView: View {
    @EnvironmentObject private var store: AppStore

    @State private var selectedCellPosition: BoardPosition = .center
    @State private var debugMessage: String?

    private var board: Board {
        store.currentBoard()
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

                    if store.profiles.isEmpty {
                        InfoCardView(
                            title: "プロフィール未登録",
                            message: "Settingsタブでプロフィールを追加すると、プロフィール連動の盤検証が可能になります。",
                            systemImage: "person.crop.circle.badge.plus"
                        )
                    }

                    Picker("盤種", selection: $store.selectedBoardType) {
                        ForEach(BoardType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("盤種")

                    BoardCanvasView(board: board, selectedCellPosition: $selectedCellPosition)

                    detailCard
                    legendCard

                    #if DEBUG
                    debugCopyButton
                    #endif
                }
                .padding()
            }
            .navigationTitle("Board")
            .onChange(of: store.selectedBoardType) { _ in
                selectedCellPosition = .center
            }
            .alert("デバッグ", isPresented: Binding(
                get: { debugMessage != nil },
                set: { if !$0 { debugMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(debugMessage ?? "")
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
        .accessibilityElement(children: .combine)
    }

    private var legendCard: some View {
        LegendCardView(markers: Marker.allCases)
    }

    #if DEBUG
    private var debugCopyButton: some View {
        Button {
            copyBoardJSON()
        } label: {
            Label("デバッグ: 現在のBoardをJSONでコピー", systemImage: "doc.on.doc")
                .frame(maxWidth: .infinity)
                .lineLimit(2)
        }
        .buttonStyle(.borderedProminent)
    }

    private func copyBoardJSON() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(board),
              let text = String(data: data, encoding: .utf8) else {
            debugMessage = "JSON生成に失敗しました"
            return
        }

        #if canImport(UIKit)
        UIPasteboard.general.string = text
        debugMessage = "現在のBoard JSONをクリップボードにコピーしました"
        #else
        debugMessage = text
        #endif
    }
    #endif
}

#Preview {
    BoardView()
        .environmentObject(AppStore())
}
