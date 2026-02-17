# 九星方位盤リニューアル版（SwiftUI土台 + 永続化）

このリポジトリには、SwiftUI(iOS 16+)で動く「九星方位盤」アプリの骨格コードを配置しています。

## 1. 収録内容

- `Sources/Domain`: ドメインモデル（`BoardType`, `AppLocation`, `DisplaySettings`, `Profile`）
- `Sources/Data`: 画面間で共有する状態管理（`AppStore`）とUserDefaultsリポジトリ
- `Sources/UI`: 4タブ構成の画面骨格（`Home / Map / Board / Settings`）
- `Sources/UI/Components`: 共通UI部品の配置先
- `Resources`: 画像・JSONなどのリソース配置先（現時点は空）

## 2. 永続化対象（UserDefaults + Codable）

- `profiles_v1`: プロフィール履歴（生年月日）
- `app_state_v1`: `selectedProfileId`, `selectedDate`, `selectedBoardType`, `selectedLocation`
- `display_settings_v1`: `displaySettings`

## 3. Xcodeプロジェクトが無い場合の最小手順

1. Xcodeで **File > New > Project... > iOS App** を作成
2. Interface を **SwiftUI**、Language を **Swift** にする
3. Deployment Target を **iOS 16.0** 以上に設定
4. 生成されたプロジェクトに、このリポジトリの `Sources` 以下の `.swift` ファイルをドラッグ&ドロップで追加
5. 既存の `@main` App struct がある場合は削除し、`Sources/UI/KyuseiRootApp.swift` をエントリポイントとして使う

> 既に `.xcodeproj` がある場合は、上記4のみでOKです（必要に応じてターゲット所属を調整）。

## 4. 実行手順

1. Xcodeでプロジェクトを開く
2. iPhoneシミュレータを選択
3. `⌘R` で実行
4. 起動後に `Home / Map / Board / Settings` の4タブが表示されることを確認
5. `Settings` タブでプロフィール追加/削除/選択後、アプリ再起動で復元されることを確認

## 5. 次タスクの進め方（提案）

1. **Mapタブ実装**: `MapKit` で地点選択・逆ジオコーディング
2. **Boardタブ実装**: 年/月/日盤の計算ロジックを `Domain` に追加
3. **Homeタブ強化**: 当日サマリ・吉方位/凶方位の表示
4. **Settings拡張**: 表示テーマ、単位、通知、データバックアップ
5. **Data層強化**: Repositoryのテスト追加、将来的な永続化方式切り替え

## 6. 共通コンポーネント（Task C）

- `DateBarView` (`Sources/UI/Components`): 前日/翌日ボタン、日付表示、カレンダー起動、1900-01-01〜2100-12-31クランプ
- `ProfilePickerButton` (`Sources/UI/Components`): 選択中プロフィール表示とボトムシート式のプロフィール切替
- `Home / Map / Board` で同一コンポーネントを利用し、`selectedDate` / `selectedProfileId` を共通同期

## 7. 盤UI（Task D）

- `Board` / `BoardCell` / `BoardPosition` / `Marker` を `Domain` に追加
- `KyuseiEngine` プロトコルと `StubKyuseiEngine` を追加し、後続Taskでロジック差し替えしやすい構成
- `BoardView` に以下を実装
  - 盤種切替（年/月/日のSegmentedControl）
  - 3x3の `BoardCanvasView`（セル選択ハイライト対応）
  - 選択セルの詳細カード
  - 凡例カード（静的表示）

## 8. 地図実装（Task E）

- `LocationManager`（CoreLocationラッパ）を追加し、権限状態監視と現在地座標取得に対応
- `MapView` を本実装化
  - 上部: `ProfilePickerButton` + `DateBarView`
  - 盤種切替（Segmented）
  - `Map` + `BoardCanvasView` オーバーレイ（北を上に固定、回転なし）
  - 透明度スライダー、地図スタイル切替、凡例表示
  - 「現在地へ」「地点を選ぶ」導線
- `LocationPickerSheet` で手動地点を選択して `selectedLocation` に保存
- 位置情報未許可時も `selectedLocation` ベースで動作

## 9. 用語解説（Task F）

- `Resources/glossary.json` を同梱し、用語をオフライン参照
- `GlossaryRepository` がBundleからJSONを読み込み、`allTerms` と `term(for: shortLabel)` を提供
- `Settings` の「用語解説一覧」から `GlossaryListView` を開ける
- `Board/Map` の `LegendCardView` で略号タップ時にBottomSheet（`GlossaryTermSheet`）を表示
- 凡例の `i` ボタンから一覧へ遷移可能

> Xcodeに取り込む際は `Resources/glossary.json` をターゲットに追加してください。
