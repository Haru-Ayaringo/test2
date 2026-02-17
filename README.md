# 九星方位盤リニューアル版（SwiftUI土台）

このリポジトリには、SwiftUI(iOS 16+)で動く「九星方位盤」アプリの骨格コードを配置しています。

## 1. 収録内容

- `Sources/Domain`: ドメインモデル（`BoardType`, `AppLocation`, `DisplaySettings`, `Profile`）
- `Sources/Data`: 画面間で共有する状態管理（`AppStore`）
- `Sources/UI`: 4タブ構成の画面骨格（`Home / Map / Board / Settings`）
- `Sources/UI/Components`: 共通UI部品の配置先
- `Resources`: 画像・JSONなどのリソース配置先（現時点は空）

## 2. Xcodeプロジェクトが無い場合の最小手順

1. Xcodeで **File > New > Project... > iOS App** を作成
2. Interface を **SwiftUI**、Language を **Swift** にする
3. Deployment Target を **iOS 16.0** 以上に設定
4. 生成されたプロジェクトに、このリポジトリの `Sources` 以下の `.swift` ファイルをドラッグ&ドロップで追加
5. 既存の `@main` App struct がある場合は削除し、`Sources/UI/KyuseiRootApp.swift` をエントリポイントとして使う

> 既に `.xcodeproj` がある場合は、上記4のみでOKです（必要に応じてターゲット所属を調整）。

## 3. 実行手順

1. Xcodeでプロジェクトを開く
2. iPhoneシミュレータを選択
3. `⌘R` で実行
4. 起動後に `Home / Map / Board / Settings` の4タブが表示されることを確認

## 4. 現在の状態管理（AppStore）

`AppStore` は `ObservableObject` で、以下を `@Published` として集約しています。

- `selectedDate: Date`
- `selectedBoardType: BoardType`
- `selectedProfileId: UUID?`
- `profiles: [Profile]`
- `selectedLocation: AppLocation`
- `displaySettings: DisplaySettings`

`KyuseiRootApp` で `environmentObject(store)` を注入し、全タブで共有可能です。

## 5. 次タスクの進め方（提案）

1. **Mapタブ実装**: `MapKit` で地点選択・逆ジオコーディング
2. **Boardタブ実装**: 年/月/日盤の計算ロジックを `Domain` に追加
3. **Homeタブ強化**: 当日サマリ・吉方位/凶方位の表示
4. **Settings拡張**: 表示テーマ、単位、通知、データバックアップ
5. **Data層強化**: 永続化（UserDefaults/JSON）とRepository分離
