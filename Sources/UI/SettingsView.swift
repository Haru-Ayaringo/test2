import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            Form {
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

                Section("プレースホルダ") {
                    Text("設定項目を順次追加予定")
                        .foregroundStyle(.secondary)
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
