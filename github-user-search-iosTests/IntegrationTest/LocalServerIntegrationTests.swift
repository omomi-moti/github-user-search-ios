import Testing
import Foundation
@testable import github_user_search_ios

//ローカルサーバー(github-user-search-api)を起動した状態で、本物のURLSessionを使って通信する結合テスト
//実行方法: TEST_RUNNER_LOCAL_SERVER=1 xcodebuild test ...(README参照)
//Swift Testingは並列に実行するため、他のテストの結果を変えないようGETだけを使う
@Suite(.enabled(if: ProcessInfo.processInfo.environment["LOCAL_SERVER"] != nil, "環境変数LOCAL_SERVERがあるときだけ実行する"))
struct LocalServerIntegrationTests {

    @Test("GET /favoritesの実際のレスポンスをServerFavoriteの配列にデコードできる")
    func fetchFavoritesFromLocalServer() async throws {
        let repository = FavoriteAPIRepository(client: APIClient(session: URLSession.shared), server: .local)

        let favorites = try await repository.fetchFavorites()

        #expect(!favorites.isEmpty)
        #expect(favorites.allSatisfy { !$0.username.isEmpty })
    }
}
