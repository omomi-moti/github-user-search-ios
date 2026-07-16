# github-user-search-ios

GitHub REST API を利用した GitHub ユーザー検索アプリです。

## 選択したトラック

iOS（Swift / SwiftUI）

## セットアップ・実行手順

1. リポジトリをclone する

   ```sh
   git clone https://github.com/omomi-moti/github-user-search-ios.git
   cd github-user-search-ios
   ```

2. Xcodeでプロジェクトを開く

   ```sh
   open github-user-search-ios.xcodeproj
   ```


3. ビルドして実行する

   - Xcode上で実行先（シミュレータ または 実機）を選択し、`Cmd + R`

## 対応OSバージョン

**iOS 17.0+**

理由: SwiftData（お気に入り永続化）・`@Observable`（状態管理）がいずれもiOS 17で導入されたAPIのため、今回の対応OSバージョンにしました。

開発・動作確認環境: Xcode 26.1.1 / Swift 6.3（言語モード: Swift 5）

## 使用ライブラリ

- [Kingfisher](https://github.com/onevcat/Kingfisher): ユーザーアバター画像の非同期読み込み・キャッシュのために採用（キャッシュ・重複リクエスト排除・スクロールアウト時のキャンセルを自前実装せずに済むため）

## 工夫した点

- 検索キーワード入力時、SwiftUIの`.task(id:)`でdebounce（300ms）を実装し、古い検索結果が最新の結果を上書きしないようにした
- `NetworkError`をケースごとにユーザー向けメッセージへマッピングし、通信エラーの原因が画面上で伝わるようにした
- `APIClientTests`を`URLSessionProtocol`経由のMockに置き換え、実ネットワークやGitHub APIのレート制限に左右されない安定したテストにした

技術選定の詳しい理由・比較検討は [docs/REPORT.md](docs/REPORT.md) を参照してください。

## 苦労した点・未対応の点

- 検索のdebounce・キャンセル処理の実装方式（自前のTask管理 / SwiftUIの`.task(id:)` / 世代番号によるキャンセル）で最適な方式を決めきれず、比較検討した。最終的に`.task(id:)`を採用したが、テスト容易性・UIフレームワーク非依存性・通信中断のどれを優先すべきかはまだ自分の中で結論が出ていない（詳細は[docs/REPORT.md](docs/REPORT.md)を参照）

## セルフレポート

AIの利用状況を含むセルフレポートは [docs/REPORT.md](docs/REPORT.md) にまとめています。
