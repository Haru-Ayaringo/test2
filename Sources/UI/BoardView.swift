import SwiftUI

struct BoardView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DateBarView()
                ProfilePickerButton()

                VStack(spacing: 12) {
                    Image(systemName: "square.grid.3x3")
                        .font(.system(size: 40))
                    Text("盤")
                        .font(.title2.bold())
                    Text("\(store.selectedBoardType.title) のプレースホルダ")
                        .foregroundStyle(.secondary)
                    Text("選択日: \(store.selectedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            .navigationTitle("Board")
        }
    }
}

#Preview {
    BoardView()
        .environmentObject(AppStore())
}
