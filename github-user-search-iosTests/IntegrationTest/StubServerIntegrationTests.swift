import Testing
import Foundation
@testable import github_user_search_ios

// スタブサーバーの接続先。テストでしか使わないので、アプリ本体ではなくここに置く
extension APIServer {
    static let stub = APIServer(scheme: "http", host: "localhost", port: 8081)
}

@Suite(.enabled(if: ProcessInfo.processInfo.environment["STUB_SERVER"] != nil, "環境変数STUB_SERVERがあるときだけ実行する"))
struct StubServerIntegrationTests {
    
    @Test("スタブサーバーからユーザー詳細を取得できる")
    func fetchUserDetail() async throws {
        let repository = GitHubAPIRepository(client: APIClient(session: URLSession.shared), server: .stub)
        
        let detail = try await repository.fetchUserDetail(username: "swiftlang")
        
        #expect(detail.login == "swiftlang")
    }
    @Test("スタブサーバーでユーザーを検索できる")
    func searchUser() async throws {
        let repository = GitHubAPIRepository(client: APIClient(session: URLSession.shared), server: .stub)
        let users = try await repository.searchUsers(keyword: "swift")
        let firstUser = try #require(users.first)
        #expect(firstUser.login == "swift")
    }
    
    @Test("スタブサーバーからリポジトリ一覧を取得できる")
    func fetchRepositories() async throws {
        let repository = GitHubAPIRepository(client: APIClient(session: URLSession.shared), server: .stub)
        let repos = try await repository.fetchUserRepositories(username: "swiftlang", page: 1)
        let firstRepo = try #require(repos.first)
        #expect(firstRepo.name == "swift")
    }
    
    @Test("特定のusernameのとき、対応するNetworkErrorになる",
          arguments: [
            ("notfound", NetworkError.notFound),
            ("ratelimited", NetworkError.rateLimited),
            ("servererror", NetworkError.serverError(statusCode: 500))
          ]
    )
    func fetchUserError(username: String,expectedError: NetworkError) async throws {
        let repository = GitHubAPIRepository(client: APIClient(session: URLSession.shared), server: .stub)
        
        await #expect(throws: expectedError) {
            _ = try await repository.fetchUserDetail(username: username)
        }
    }
}
