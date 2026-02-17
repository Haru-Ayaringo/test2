import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            Form {
                ProfileListView()

                Section("基本状態") {
                    DatePicker("選択日", selection: $store.selectedDate, displayedComponents: .date)
                    Picker("盤種", selection: $store.selectedBoardType) {
                        ForEach(BoardType.allCases) { boardType in
                            Text(boardType.title).tag(boardType)
                        }
                    }
                }

                Section("表示設定") {
                    Slider(value: $store.displaySettings.overlayOpacity, in: 0...1) {
                        Text("オーバーレイ不透明度")
                    }
                    Text("オーバーレイ不透明度: \(store.displaySettings.overlayOpacity, specifier: "%.2f")")
                    Picker("地図スタイル", selection: $store.displaySettings.mapStyle) {
                        ForEach(DisplaySettings.MapStyle.allCases) { style in
                            Text(style.title).tag(style)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppStore())
}
