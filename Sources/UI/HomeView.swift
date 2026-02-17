import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            List {
                Section("今日の要約") {
                    Text("選択日: \(store.selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    Text("盤種: \(store.selectedBoardType.title)")
                    Text("地点: \(store.selectedLocation.name ?? "未設定")")
                }

                Section("プレースホルダ") {
                    Text("ここに本日の九星サマリを表示予定")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppStore())
}
