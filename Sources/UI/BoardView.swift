import SwiftUI

struct BoardView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "square.grid.3x3")
                    .font(.system(size: 40))
                Text("盤")
                    .font(.title2.bold())
                Text("\(store.selectedBoardType.title) のプレースホルダ")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .navigationTitle("Board")
        }
    }
}

#Preview {
    BoardView()
        .environmentObject(AppStore())
}
