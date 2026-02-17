import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DateBarView()
                ProfilePickerButton()

                VStack(spacing: 12) {
                    Image(systemName: "map")
                        .font(.system(size: 40))
                    Text("地図")
                        .font(.title2.bold())
                    Text("後続タスクで MapKit 表示を実装します")
                        .foregroundStyle(.secondary)
                    Text("現在地点: \(store.selectedLocation.name ?? "未設定")")
                        .font(.footnote)
                    Text("選択日: \(store.selectedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            .navigationTitle("Map")
        }
    }
}

#Preview {
    MapView()
        .environmentObject(AppStore())
}
