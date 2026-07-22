# セルフレポート

**うまくいかなかったこと・分からなかったことを正直に書くことは、減点対象ではありません。**

---

## 1. 基本情報

- 氏名（ニックネーム化）: 鈴木聖也(おもち)
- 選択トラック: iOS 
- 開発環境（OS / IDE / 言語バージョン）: macOS 26.5.1 / Xcode 26.1.1 (17B100) / Swift 6.3（言語モード: Swift 5）
- 対応 OS バージョン:17+\
 理由: SwiftData（お気に入り永続化）、@Observable（状態管理）がいずれもiOS 17で導入されたAPIのため。
- 開発にかけたおおよその時間:20時間程度

## 2. 実装した機能

必須要件・ボーナス要件のうち、対応したものにチェックを入れてください。

### 必須要件

- [x] キーワードでユーザー検索
- [x] 検索結果の一覧表示
- [x] ユーザー詳細表示（アイコン・名前・bio・フォロワー数など）
- [x] リポジトリ一覧表示
- [x] リポジトリ情報の表示（説明・言語・スター数など）
- [x] 端末ブラウザでページを開く
- [x] ローディング / エラー状態の表現
- [x] API 通信の自前実装
- [x] ローカル保存（再起動後も復元できる。保存手段: UserDefaults + SwiftData / 保存対象: 検索履歴(UserDefaults) / お気に入りユーザー(SwiftData)）\
- [x] （iOS）SwiftUI メイン + UIKit 連携を 1 箇所以上
- [ ] （Android）Jetpack Compose での実装

### ボーナス要件（対応したものだけ）

- [x] Unit テスト
- [x] ダークモード対応(標準的なコンポーネントしか使用していないため、SwiftUI側が自動で対応してくれている)
- [x] 画像キャッシュ（Kingfisher）
- [x] リトライ処理(RetryViewによるユーザー手動リトライ)
- [x] ページネーション

## 3. 設計・技術選定について

### 技術選定について

1, URLSession\
使用箇所: GitHub REST API（ユーザー検索・ユーザー詳細取得、ユーザーのリポジトリ情報の取得）との通信にURLSessionを採用した。\
具体的な使い方: GitHub Search API（/search/users）、ユーザー詳細API（/users/{username}）、リポジトリ一覧API（/users/{username}/repos）へのGETリクエストをURLSession.shared.data(for:)で叩き、返ってきたJSONをDecodableでモデルにマッピングしている。

2, SwiftTesting\
使用箇所: URL組み立て・API通信・Repository・ViewModel・UserDefaults永続化など、テスト可能な各層に採用した。\
具体的な使い方: 各層に対応するテストファイル(EndpointTests, APIClientTests, RepositoryTests, SearchViewModelTests, UserDetailViewModelTests, FavoriteViewModelTests, SearchHistoryStoreTests)で、対象の振る舞いを#expectで検証している。\
SwiftTestingの採用理由\
1, テストの意図を構造として表現しやすい: @Testアトリビュートを記載することで明示的にテストであることがわかりやすい。\
2, アサーション表現が統一されている: #expectで表現でき、XCTestのXCTAssertEqualやXCTAssertFalseのような使い分けが不要である。

3, UserDefaults\
使用箇所: 検索キーワードの履歴保存に採用した。\
具体的な使い方: SearchHistoryStoreが検索実行時のキーワードを[String]としてJSONEncode/Decodeし、UserDefaultsに1つのキーで保存・読み込みしている。重複キーワードは先頭に移動、保存件数は20件を上限として超過分は末尾から間引く形にしている。\
UserDefaultsの採用理由\
1, データの性質に見合った実装だと判断したため：検索履歴は「順序付きの単純なリスト」であり、複数テーブル間の関連や複雑な検索条件を必要としない。この規模のデータにSwiftDataやCoreDataのようなデータベースを使用するのはオーバーエンジニアリングだと判断した。

4, SwiftData\
使用箇所: お気に入りユーザーの保存に採用した。\
具体的な使い方: @Modelを付与したFavoriteUserクラス（username, avatarURL, name, savedAt）を定義し、ModelContainer経由で永続化する。他モデルとの関連（リレーション）は持たせず、単一モデルにとどめている。\
SwiftDataの採用理由\
1, データの性質に見合った実装だと判断したため：お気に入りは登録・削除の操作に加え、将来的な並び替えや絞り込みの余地があるデータであり、検索履歴（UserDefaults）とは異なりクエリ可能な手段が適していると判断した。

5, Observation（@Observable）\
使用箇所: SearchViewModel、UserDetailViewModel、FavoriteViewModelの状態管理。\
具体的な使い方: 各ViewModelを@Observable＋@MainActorのclassにし、SearchViewModelとUserDetailViewModelではViewState<T>をプロパティとして持たせている。\
採用理由: ObservableObject＋@Published（Combine）と比べ、付け忘れの心配がなく参照プロパティ単位で再描画が最適化されるため。\

6, Swift Concurrency（async/await, Task）\
使用箇所: API通信全般、検索のdebounce制御、詳細画面の並行取得。\
具体的な使い方: GitHubRepositoryをasync throwsで定義し、SearchViewModelは.task(id:)による自動キャンセル＋Task.isCancelledで古い検索結果を破棄、UserDetailViewModelはasync letでプロフィールとリポジトリを並行取得している。\
採用理由:\
1, 従来のクロージャを用いた非同期処理と比べ、処理を同期的に書けて可読性が高い\
2, .task(id:)とTask.isCancelledの組み合わせで「最新の結果だけ反映する」制御をシンプルに実現できること\
3, @MainActorによってUI更新のスレッド安全性がコンパイラレベルで保証される\

7, SwiftUI\
使用箇所: 全画面。\
具体的な使い方: NavigationStack + searchable + navigationDestinationで遷移、TabViewで検索/お気に入りを切り替え。@State + @ObservableでViewModelと繋ぎ、@Query + @EnvironmentでSwiftDataを扱う。
採用理由:\
1, 宣言的UIで「状態→見た目」が一対一になり、状態のズレによるバグが起きにくい\
2, @Observable/@Query/.taskなど状態管理・非同期・DBとの繋ぎ込みが容易\

8, Kingfisher\
使用箇所: ユーザーアバターの画像表示(AvatarImageに集約)。\
具体的な使い方: KFImage(URL(string:))にresizable/placeholder/frame/clipShapeを繋いで表示。\
採用理由(URLSession自前実装との比較):\
1, キャッシュ・重複リクエスト排除・UIImage変換を自前で書かずに済む\
2, リストのスクロールで見えなくなった画像リクエストを自動でキャンセルしてくれる\
3, KFImage自体がSwiftUIのViewなので、AsyncImage同様に宣言的に書ける\

9, UIKit\
使用箇所: SafariView.swiftでSwiftUI ↔ UIKitのブリッジ層として利用。\
具体的な使い方: UIViewControllerRepresentable(UIKitのUIViewControllerをSwiftUIから扱うためのプロトコル)を実装し、makeUIViewController/updateUIViewController経由でSFSafariViewControllerを組み込む。\
採用理由:\
1, SwiftUIには「Safariでページを開く」正式な手段が無く、UIKit(SFSafariViewController)を利用するにはUIViewControllerRepresentableでのラップが必要だった

10, SFSafariViewController(SafariServices)\
使用箇所: 詳細画面のリポジトリ行タップ時に、GitHub上の該当ページをアプリ内で表示。\
具体的な使い方: UIViewControllerRepresentableでラップしたSafariViewを、UserDetailViewの.sheet(item:)でモーダル表示する。\
採用理由:\
1, WKWebViewを自前実装する場合と比べ、Safari標準UI(進む/戻る/共有/リーダーモード/完了ボタン)がそのまま使え、実装コストが低い\
2, Safari本体とCookieを共有するため、ユーザーがGitHubにログイン済みなら、そのままログイン状態でページを閲覧できる

### 設計について

1, リポジトリ層の導入\
役割: API通信とViewModelとの間に入り、実際のデータ取得処理を実行する層として実装\
採用理由: ViewModelから通信部分の実装を切り離すことで、ViewModelの責務の範囲を減らすことができるため

2, リポジトリパターン（protocolによる抽象化）\
使用箇所: URLSessionで実際にfetchする部分をprotocolとして抽象化し、本番実装（実際の通信処理）とモック（テスト用ダミーデータ）を切り替え可能にするために使用\
採用理由: URLSessionの処理部分の抽象度を上げ、モックか本番の通信処理かをViewModelから隠蔽することで、元のコードを変更せずとも単体テストを行えるようになるため

3, MVVM\
使用箇所: ロジック層全体(SearchViewModel, UserDetailViewModel, FavoriteViewModel)。\
具体的な使い方: @Observable + @MainActorでViewModelを定義し、画面状態はViewState<T>(idle/loading/loaded/error)で表現。Repository層はprotocolで注入する。\
採用理由(MVCとの比較):\
1, MVCはViewController肥大化(Massive View Controller)を起こしやすいが、MVVMはロジックをViewModelに切り出せる\
2, ViewModelがUIに依存しないため、Mockを注入したUnit Testが書ける\
3, ViewModelがViewに依存しない構造になるため、UIフレームワークの変更やUIの作り替えの影響をViewModel側が受けにくい

## 4. 工夫した点・こだわった点

① Taskキャンセル部分（SearchViewModel）\
問題: 検索キーワードを素早く入力した際、前の検索リクエストがキャンセルされずに走り続け、後から古い結果で最新の結果を上書きしてしまう可能性があった\
解決方法: SwiftUIの.task(id:)にTask管理を委ね、keywordが変わるたびに前のTaskを自動キャンセルさせたうえで、await直後に guard !Task.isCancelled else { return } で二重チェックを入れた

② エラーメッセージ表示の粒度の改善(NetworkError × ViewModel)\
問題: 元々の実装ではエラーキャッチ時にユーザーへ表示されるメッセージが、画面ごとに1種類の固定文言(「検索に失敗しました」など)しかなく、ユーザーが何が原因でエラーが出ているのか、次に何をすべきかが分かりにくかった。\
解決方法: エラーの状態が定義されているNetworkErrorをextensionして、caseごとに対応するエラーメッセージを持たせ、ViewModelのcatch内でキャッチしたエラーに対応した文を受け取りViewに表示する実装に変更した。

③ APIClientTestsのネットワーク非依存化(APIClient × URLSessionProtocol × MockURLSession)\
問題: 元々のAPIClientTestsは実際にGitHubの本番APIへリクエストを送る実装になっており、ネットワーク不通時やレート制限(60回/時)超過時にテストが失敗したり、検索結果の順位変動によってアサーションがずれたりと、テストの安定性がコードの正しさとは無関係な要因に左右されていた。\
解決方法: URLSessionをそのまま使うのではなく、data(for:)だけを切り出したURLSessionProtocolを定義し、APIClientの初期化時に注入できるようにした(本番はURLSessionをそのままextensionで適合させ、テスト時は固定のステータスコードとJSONを返すMockURLSessionに差し替え)。これによりテストは実ネットワークに一切触れず、GitHub APIが実際に返しうる各ステータスコード(200/403/404/422/500/未知)に対して、NetworkErrorの該当ケースと関連値(statusCodeなど)まで一致するかを検証する構成にした。

## 5. 苦労した点・分からなかった点・未対応の点

非同期処理でのTaskキャンセル手法の選定

1,検索のdebounce＋キャンセル処理について、実装方法を3パターンで検討し、最終的にどれが良いか迷った点。

1つ目は、`SearchViewModel`が自前で`Task`を保持し、`cancel()`を明示的に呼んで管理する方式。ViewModel単体で挙動が完結し、UIフレームワークに依存しない（UIKit画面からでも同じ挙動を呼び出せる）というMVVMの利点を保ちやすい一方、`nonisolated(unsafe)`や`deinit`でのキャンセルなど、実装者自身が並行処理の安全性に気を配らなければいけない箇所が増える。

2つ目は、SwiftUIの`.task(id:)`にTaskの生成・キャンセル・View破棄時の後始末を任せる方式。実装は簡潔になり、テストも書きやすくなるが、「いつ検索するか」というトリガーの判断がView側に移るため、ViewModelとViewの結合度が上がり、ViewModel単体では挙動が完結しなくなる。

3つ目は、`Task`のキャンセルを使わず、検索のたびに世代番号（generation）をインクリメントし、結果が返ってきた時点で最新の世代かどうかを比較して古ければ捨てる方式。ViewModel単体で完結する点は1つ目に近いメリットだが、通信中に世代が進んだ場合はその通信自体は中断できず、結果を捨てるだけになる。GitHub APIのレート制限を踏まえるとこの点はTaskキャンセル方式に劣ると考えた。

3つともメリット、デメリットがあり、最終的には実装の簡潔さを優先して`.task(id:)`方式を採用したが、テスト容易性・UIフレームワーク非依存性・通信そのものの中断のどれを優先すべきかは状況次第だと思われ、どれが「ベスト」なのかについては、まだ自分の中で結論が出せておらず、引き続き勉強が必要だなと感じました。

2,検索結果0件時の空状態表示に`ContentUnavailableView.search`を使うか、自前で日本語文言を指定するかがわからなかった。`.search`はローカライズ済みだが、プロジェクトのLocalizationsにjaが未設定だと英語にフォールバックする。今回はアプリ全体で日本語文言を直書きしている方針に合わせ、自前で文言を指定する方式を採用した。

3,テストの粒度・スコープの判断が難しかった。「どこまでテストすべきか」「その層のテストで何を検証すべきか」の線引きに迷った。今回は各層のテストが「その層自身の責務だけを検証する」方針を意識して整理した（Network層はHTTP→エラー変換とデコード、Repository層は部品の結合、ViewModel層は状態遷移）。ただしテストの網羅性や粒度の最適解についてはまだ手探りの部分が多く、難しいと感じました。

## 6. 生成 AI の利用について

- 利用した AI ツール: claude code
- AI が生成したコードのうち、内容を理解し、自分で説明できる状態にしたか:
  - [x] はい、提出したコードはすべて自分で説明できます

今回の実装でAIを主な使用用途

① アーキテクチャの一貫性レビュー\
リポジトリパターン・MVVMを、テスト容易性や抽象度の向上を目的として採用する判断をした。開発が進むにつれて設計判断がぶれないよう、実装全体を通してAIにアーキテクチャの一貫性をレビューしてもらった。

② 未経験技術のキャッチアップ\
UIKit（UIViewControllerRepresentable等）のように触れたことのない技術を使う際は、まず公式リファレンスや、Qiitaなどで実装を確認し、理解が難しかった部分をAIに質問して壁打ちしながら理解を深めてから実装した。

③ 定型的な処理のコード生成\
既存の実装と同じパターンだと判断できる処理は、Claude Codeにコード生成を任せた。ただし、初めて書くパターンや設計判断が絡む部分は、まず自分の手で実装することを意識した。

④ コードレビュー\
PRを出す前に、実装内容に矛盾がないか、命名規則やアーキテクチャの一貫性が保たれているかをAIにレビューしてもらい、指摘を都度反映していた。

⑤ 要件・評価観点との突き合わせ\
課題の評価観点（説明可能性・設計・コード品質など）に沿って実装をAIと一緒に見直し、抜けていた点（お気に入り画面の空状態未対応、対応OSバージョンの妥当性など）を洗い出して修正した。

⑥ GitHub APIの調査\
GitHub REST APIの各エンドポイントについて、レスポンスのJSON構造やステータスコードごとの挙動をAIに調査してもらった。そのうえで、モデルにどのフィールドを含めるか、どのステータスコードをどのエラーケースとして扱うかは自分で判断して実装した。

## 7. 参考にした情報源（任意）

- （公式ドキュメント、記事、質問サイトなど）

1, [Swift TestingとXCTestを使い比べてみました - Qiita](https://qiita.com/dolu/items/6a5b2af12f51018a5829)：Swift TestingとXCTestの技術選定比較に関して考える際に使用しました

2, [アプリ アーキテクチャ ガイド | App architecture - Android Developers](https://developer.android.com/topic/architecture?hl=ja)：リポジトリ層の役割（データソースの抽象化、関心の分離）を理解する際の参考として使用しました

3, [UserDefaultsの概要と操作方法(Swift) - Qiita](https://qiita.com/uhooi/items/429cac9b798b9c0937ae)：UserDefaultsの基本的なCRUD操作や定義の仕方などを理解する参考として使いました

4, [SwiftDataめっちゃええやん。 - Qiita](https://qiita.com/dokozon0/items/0c46c432b2e873ceeb04)：@Modelの定義方法、ModelContainerの注入、context.insert()/context.delete()によるCRUD操作の基本的な流れを理解する参考として使いました

5, [SwiftのEquatableプロトコルを基礎から - Qiita](https://qiita.com/imchino/items/793bccb0384c8460d267)：`Equatable`プロトコルに準拠させることで、オブジェクト同士が同じかどうかを比較できるようになる仕組みを理解する参考として使いました。

6, [deinitについて - Qiita](https://qiita.com/dogtown/items/2fe6bb8581e7e33950ad)：`deinit`がインスタンス解放時に呼ばれる仕組みと、ARC（Automatic Reference Counting）下でのメモリ管理の基本を理解する参考として使いました。Taskのキャンセル制御を`deinit`で行う際、クロージャが`self`を強参照していると`deinit`自体が呼ばれず意味をなさないケースがあることに気づくきっかけになりました

7, [MVCとMVVMアーキテクチャの違いを理解する - Qiita](https://qiita.com/k_hirofumi/items/a01a0eeef235eeef7f73)：アーキテクチャ選定にあたり、MVCとMVVMそれぞれのデータフロー・責任範囲・テストのしやすさを比較検討する参考として使いました。

8, [UIKitのUIViewController/UIViewをSwiftUIで利用する場合の利用方法とその詳細 - Qiita](https://qiita.com/yimajo/items/791dc1c1693d9821c5a8)：SafariView.swiftでSFSafariViewControllerをSwiftUIから使う際、UIViewControllerRepresentableの実装テンプレート、makeUIViewController/updateUIViewControllerの呼ばれ方を確認する参考として使いました。

9, [Unit Testを始めよう①~DI・モック・スタブ・Modelのテスト~ #Swift - Qiita](https://qiita.com/hinakko/items/8a34ef105087d831580b)：APIClientTestsをネットワークに依存せず検証できるようにする際、URLSessionをプロトコルで抽象化してMockに差し替えるDIの構成、およびステータスコードごとにテストケースを分ける粒度の参考にしました。

10, [【SwiftUI】ContentUnavailableViewの使い方 - Qiita](https://qiita.com/stotic-dev/items/97f605f034c79a860789)：検索結果0件・リポジトリ0件・お気に入り0件時の空状態表示にContentUnavailableViewを採用する際、使い方を参考にしました。