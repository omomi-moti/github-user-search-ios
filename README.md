# セルフレポート（テンプレート）

このファイルをコピーして `REPORT.md` などの名前で提出物に同梱してください。
**うまくいかなかったこと・分からなかったことを正直に書くことは、減点対象ではありません。**

---

## 1. 基本情報

- 氏名（ニックネーム化）:
- 選択トラック: iOS / Android
- 開発環境（OS / IDE / 言語バージョン）:
- 対応 OS バージョン:
- 開発にかけたおおよその時間:

## 2. 実装した機能

必須要件・ボーナス要件のうち、対応したものにチェックを入れてください。

### 必須要件

- [x] キーワードでユーザー検索
- [x] 検索結果の一覧表示
- [x] ユーザー詳細表示（アイコン・名前・bio・フォロワー数など）
- [x] リポジトリ一覧表示
- [x] リポジトリ情報の表示（説明・言語・スター数など）
- [ ] 端末ブラウザでページを開く
- [] ローディング / エラー状態の表現
- [x] API 通信の自前実装
- [x] ローカル保存（再起動後も復元できる。保存手段: UserDefaults + SwiftData / 保存対象: 検索履歴(UserDefaults) / お気に入りユーザー(SwiftData)）\
- [ ] （iOS）SwiftUI メイン + UIKit 連携を 1 箇所以上
- [ ] （Android）Jetpack Compose での実装

### ボーナス要件（対応したものだけ）

- [ ] （例）Unit テスト
- [ ] （例）ダークモード対応
- [ ] （例）その他:

## 3. 設計・技術選定について
技術選定について\
1,URLSession\
使用箇所:GitHub REST API（ユーザー検索・ユーザー詳細取得、ユーザーのリポジトリ情報の取得）との通信にURLSessionを採用した。\
具体的な使い方: GitHub Search API（/search/users）、ユーザー詳細API（/users/{username}）、リポジトリ一覧API（/users/{username}/repos）へのGETリクエストをURLSession.shared.data(for:)で叩き、返ってきたJSONをDecodableでモデルにマッピングしている。

2, SwiftTesting\
使用箇所: URL組み立て・API通信・Repository・ViewModel・UserDefaults永続化など、テスト可能な各層に採用した。\
具体的な使い方: 各層に対応するテストファイル(EndpointTests, APIClientTests, RepositoryTests, SearchViewModelTests, UserDetailViewModelTests, FavoriteViewModelTests, SearchHistoryStoreTests)で、対象の振る舞いを#expectで検証している。\
SwiftTestingの採用理由\
1, テストの意図を構造として表現しやすい: @Testアトリビュートを記載することで明示的にテストであることがわかりやすい。\
2, アサーション表現が統一されている: #expectで表現でき、XCTestのXCTAssertEqualやXCTAssertFalseのような使い分けが不要である。

3,UserDefaults\
使用箇所: 検索キーワードの履歴保存に採用した。\
具体的な使い方: SearchHistoryStoreが検索実行時のキーワードを[String]としてJSONEncode/Decodeし、UserDefaultsに1つのキーで保存・読み込みしている。重複キーワードは先頭に移動、保存件数は20件を上限として超過分は末尾から間引く形にしている。\
UserDefaultsの採用理由\
1,データの性質に見合った実装だと判断したため：検索履歴は「順序付きの単純なリスト」であり、複数テーブル間の関連や複雑な検索条件を必要としない。この規模のデータにSwiftDataやCoreDataのようなデータベースを使用するのはオーバーエンジニアリングだと判断した。

4,SwiftData\
使用箇所: お気に入りユーザーの保存に採用した。\
具体的な使い方: @Modelを付与したFavoriteUserクラス（username, avatarURL, name, savedAt）を定義し、ModelContainer経由で永続化する。他モデルとの関連（リレーション）は持たせず、単一モデルにとどめている。\
SwiftDataの採用理由\
1,データの性質に見合った実装だと判断したため：お気に入りは登録・削除の操作に加え、将来的な並び替えや絞り込みの余地があるデータであり、検索履歴（UserDefaults）とは異なりクエリ可能な手段が適していると判断した。

5,Observation（@Observable）\
使用箇所: SearchViewModel、UserDetailViewModel、FavoriteViewModelの状態管理。\
具体的な使い方: 各ViewModelを@Observable＋@MainActorのclassにし、ViewState<T>をプロパティとして持たせている。\
採用理由: ObservableObject＋@Published（Combine）と比べ、付け忘れの心配がなく参照プロパティ単位で再描画が最適化されるため。\

6,Swift Concurrency（async/await, Task）\
使用箇所: API通信全般、検索のdebounce制御、詳細画面の並行取得。\
具体的な使い方: GitHubRepositoryをasync throwsで定義し、SearchViewModelはTaskのキャンセル＋Task.isCancelledで古い検索結果を破棄、UserDetailViewModelはasync letでプロフィールとリポジトリを並行取得している。\
採用理由:
1,従来のクロージャを用いた非同期処理と比べ、処理を同期的に書けて可読性が高い\
2,Task.cancel()だけで「最新の結果だけ反映する」制御をシンプルに実現できること\
3,@MainActorによってUI更新のスレッド安全性がコンパイラレベルで保証される\

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

設計について

1, リポジトリ層の導入\
役割：API通信とViewModelとの間に入り、実際のデータ取得処理を実行する層として実装\
採用理由：ViewModelから通信部分の実装を切り離すことで、ViewModelの責務の範囲を減らすことができるため

2, リポジトリパターン（protocolによる抽象化）\
使用箇所：URLSessionで実際にfetchする部分をprotocolとして抽象化し、本番実装（実際の通信処理）とモック（テスト用ダミーデータ）を切り替え可能にするために使用\
採用理由：URLSessionの処理部分の抽象度を上げ、モックか本番の通信処理かをViewModelから隠蔽することで、元のコードを変更せずとも単体テストを行えるようになるため

3, MVVM\
使用箇所: ロジック層全体(SearchViewModel, UserDetailViewModel, FavoriteViewModel)。\
具体的な使い方: @Observable + @MainActorでViewModelを定義し、画面状態はViewState<T>(idle/loading/loaded/error)で表現。Repository層はprotocolで注入する。\
採用理由(MVCとの比較):\
1, MVCはViewController肥大化(Massive View Controller)を起こしやすいが、MVVMはロジックをViewModelに切り出せる\
2, ViewModelがUIに依存しないため、Mockを注入したUnit Testが書ける\
3, ViewModelがViewに依存しない構造になるため、UIフレームワークの変更やUIの作り替えの影響をViewModel側が受けにくい\


## 4. 工夫した点・こだわった点

① Taskキャンセル部分（UserDetailViewModel)

- 問題: ユーザー画面を素早く切り替えたとき、キャンセルされた古いリクエストの成功/失敗処理がそのまま実行され、新しいリクエストの結果を後から上書きしてしまう可能性があった
- 解決方法: `await`直後と`catch`内に`guard !Task.isCancelled else { return }`を入れ、キャンセル済みなら状態更新をスキップするようにした
- 解決できたこと: 古い（もう不要になった）リクエストの結果で`detailState`/`repoState`が誤って上書きされなくなり、常に「今表示すべきユーザー」の状態だけが画面に反映されるようになった


## 5. 苦労した点・分からなかった点・未対応の点

- （今後対応）APIClientTestsが実APIに依存：モックなしで本物のGitHub APIを叩いているため、レート制限（60回/時）や実データ依存でテストが不安定になりやすい。URLProtocolによるスタブ化を検討中。

## 6. 生成 AI の利用について

- 利用した AI ツール:
- AI が生成したコードのうち、内容を理解し、自分で説明できる状態にしたか:
  - [ ] はい、提出したコードはすべて自分で説明できます

## 7. 参考にした情報源（任意）

- （公式ドキュメント、記事、質問サイトなど）

1, [Swift TestingとXCTestを使い比べてみました - Qiita](https://qiita.com/dolu/items/6a5b2af12f51018a5829)：Swift TestingとXCTestの技術選定比較に関して考える際に使用しました

2, [アプリ アーキテクチャ ガイド | App architecture - Android Developers](https://developer.android.com/topic/architecture?hl=ja)：リポジトリ層の役割（データソースの抽象化、関心の分離）を理解する際の参考として使用しました

3, [UserDefaultsの概要と操作方法(Swift) - Qiita](https://qiita.com/uhooi/items/429cac9b798b9c0937ae)：UserDefaultsの基本的なCRUD操作や定義の仕方などを理解する参考として使いました

4, [SwiftDataめっちゃええやん。 - Qiita](https://qiita.com/dokozon0/items/0c46c432b2e873ceeb04)：@Modelの定義方法、ModelContainerの注入、context.insert()/context.delete()によるCRUD操作の基本的な流れを理解する参考として使いました

5, [SwiftのEquatableプロトコルを基礎から - Qiita](https://qiita.com/imchino/items/793bccb0384c8460d267)：`Equatable`プロトコルに準拠させることで、オブジェクト同士が同じかどうかを比較できるようになる仕組みを理解する参考として使いました。

6, [deinitについて - Qiita](https://qiita.com/dogtown/items/2fe6bb8581e7e33950ad)：`deinit`がインスタンス解放時に呼ばれる仕組みと、ARC（Automatic Reference Counting）下でのメモリ管理の基本を理解する参考として使いました。Taskのキャンセル制御を`deinit`で行う際、クロージャが`self`を強参照していると`deinit`自体が呼ばれず意味をなさないケースがあることに気づくきっかけになりました

7, [MVCとMVVMアーキテクチャの違いを理解する - Qiita](https://qiita.com/k_hirofumi/items/a01a0eeef235eeef7f73)：アーキテクチャ選定にあたり、MVCとMVVMそれぞれのデータフロー・責任範囲・テストのしやすさを比較検討する参考として使いました。