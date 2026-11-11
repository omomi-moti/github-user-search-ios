# github-user-search-ios

GitHub のユーザーをキーワードで検索し、プロフィールやリポジトリをすばやく確認できる iOS アプリです。気になったユーザーは、端末とサーバーの両方にお気に入りとして保存できます。

## 主な機能

- **ユーザー検索**: キーワードを入力すると、300ms の debounce 後に GitHub REST API で自動検索します
- **ユーザー詳細**: アイコン・フォロワー数・フォロー数・リポジトリ一覧を確認でき、リポジトリはアプリ内で開けます
- **お気に入り**: 端末内（SwiftData）とサーバーの2か所に保存でき、サーバー側はスワイプで削除できます
- **エラー表示と再試行**: 通信エラーの原因を画面上で伝え、ワンタップで再試行できます

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

## テストの実行

### ユニットテスト

```sh
xcodebuild test \
  -project github-user-search-ios.xcodeproj \
  -scheme github-user-search-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:github-user-search-iosTests
```

### ローカルサーバーとの結合テスト

`LocalServerIntegrationTests` は、ローカルサーバー（[github-user-search-api](https://github.com/omomi-moti/github-user-search-api)）を起動した状態で、本物の `URLSession` を使って通信するテストです。環境変数 `LOCAL_SERVER` があるときだけ実行され、ないときはスキップされます。

1. ローカルサーバーを起動する（`localhost:8080` で待ち受けます）

   ```sh
   cd github-user-search-api
   go run .
   ```

2. 別のターミナルで、環境変数を付けてテストを実行する

   ```sh
   TEST_RUNNER_LOCAL_SERVER=1 xcodebuild test \
     -project github-user-search-ios.xcodeproj \
     -scheme github-user-search-ios \
     -destination 'platform=iOS Simulator,name=iPhone 17' \
     -only-testing:github-user-search-iosTests
   ```

   - `xcodebuild` は `TEST_RUNNER_` を付けた環境変数を、先頭の `TEST_RUNNER_` を外してテストプロセスに渡します（`TEST_RUNNER_LOCAL_SERVER` → `LOCAL_SERVER`）

### スタブサーバーとの結合テスト

`StubServerIntegrationTests` は、GitHub API と同じ形のレスポンスを返すスタブサーバー（[github-user-search-api](https://github.com/omomi-moti/github-user-search-api) の `stub/`）を起動した状態で、本物の `URLSession` と `GitHubAPIRepository` を使って通信するテストです。環境変数 `STUB_SERVER` があるときだけ実行され、ないときはスキップされます。

スタブサーバーは、特定の username・キーワードのときにエラーを返します。

| username・キーワード | ステータス | `NetworkError` |
|---|---|---|
| `notfound` | 404 | `notFound` |
| `ratelimited` | 403 | `rateLimited` |
| `servererror` | 500 | `serverError(statusCode: 500)` |

1. スタブサーバーを起動する（`localhost:8081` で待ち受けます）

   ```sh
   cd github-user-search-api
   go run ./stub
   ```

2. 別のターミナルで、このリポジトリに移動してから、環境変数を付けてテストを実行する

   ```sh
   cd github-user-search-ios
   TEST_RUNNER_STUB_SERVER=1 xcodebuild test \
     -project github-user-search-ios.xcodeproj \
     -scheme github-user-search-ios \
     -destination 'platform=iOS Simulator,name=iPhone 17' \
     -only-testing:github-user-search-iosTests/StubServerIntegrationTests
   ```

   - テストのコマンドは、スタブサーバーを起動したターミナル（github-user-search-api）ではなく、このリポジトリで実行します。違う場所で実行すると `xcodebuild: error: 'github-user-search-ios.xcodeproj' does not exist.` になります
   - スタブサーバーを起動していないと、すべてのテストが `NSURLErrorDomain Code=-1004`（接続できない）で失敗します

## 対応OSバージョン

**iOS 17.0+**

理由: SwiftData（お気に入り永続化）・`@Observable`（状態管理）がいずれもiOS 17で導入されたAPIのため、今回の対応OSバージョンにしました。

開発・動作確認環境: Xcode 26.1.1 / Swift 6.3（言語モード: Swift 5）

## 使用ライブラリ

- [Kingfisher](https://github.com/onevcat/Kingfisher): ユーザーアバター画像の非同期読み込み・キャッシュのために採用（キャッシュ・重複リクエスト排除を自前実装せずに済むため）

## 工夫した点

- 検索キーワード入力時、`SearchViewModel`で300msのdebounceを入れ、SwiftUIの`.task(id:)`によるキャンセルと組み合わせることで、古い検索結果が最新の結果を上書きしないようにした
- `NetworkError`をケースごとにユーザー向けメッセージへマッピングし、通信エラーの原因が画面上で伝わるようにした
- `APIClientTests`を`URLSessionProtocol`経由のMockに置き換え、実ネットワークやGitHub APIのレート制限に左右されない安定したテストにした

技術選定の詳しい理由・比較検討は [docs/REPORT.md](docs/REPORT.md) を参照してください。

## セルフレポート

設計で苦労した点・未対応の点、AIの利用状況を含むセルフレポートは [docs/REPORT.md](docs/REPORT.md) にまとめています。
