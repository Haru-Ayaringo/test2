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
                    .accessibilityLabel("オーバーレイ不透明度")

                    Text("オーバーレイ不透明度: \(store.displaySettings.overlayOpacity, specifier: "%.2f")")

                    Picker("地図スタイル", selection: $store.displaySettings.mapStyle) {
                        ForEach(DisplaySettings.MapStyle.allCases) { style in
                            Text(style.title).tag(style)
                        }
                    }
                }

                Section("ヘルプ") {
                    NavigationLink("用語解説一覧") {
                        GlossaryListView()
                    }

                    InfoCardView(
                        title: "注意事項",
                        message: "九星の解釈は流派により異なる場合があります。地図表示は端末の位置精度・地図誤差の影響を受けるため、最終判断は現地情報も確認してください。",
                        systemImage: "exclamationmark.triangle"
                    )
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
