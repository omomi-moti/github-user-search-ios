import Testing
import Foundation
@testable import github_user_search_ios

struct RepositoryTests {

    private func makeRepository(statusCode: Int, json: String) -> GitHubAPIRepository {
        let data = json.data(using: .utf8)!
        let client = APIClient(session: MockURLSession(statusCode: statusCode, data: data))
        return GitHubAPIRepository(client: client)
    }

    @Test("検索が成功した場合、SearchUserの配列が返る")
    func searchUsersSucceeds() async throws {
        let repository = makeRepository(statusCode: 200, json: """
        {
          "total_count": 1,
          "incomplete_results": false,
          "items": [
            {"id": 1, "login": "swift", "avatar_url": "https://example.com/a.png"}
          ]
        }
        """)
        let users = try await repository.searchUsers(keyword: "swift")

        #expect(users.count == 1)
        #expect(users.first?.login == "swift")
    }

    @Test("ユーザーの詳細情報が取得できた場合、UserDetailが返る")
    func getUserDetailSucceeds() async throws {
        let repository = makeRepository(statusCode: 200, json: """
        {
          "login": "swift",
          "name": "The Swift",
          "bio": null,
          "followers": 100,
          "following": 0,
          "avatar_url": "https://example.com/a.png"
        }
        """)
        let detail = try await repository.fetchUserDetail(username: "swift")

        #expect(detail.login == "swift")
        #expect(detail.followers == 100)
    }

    @Test("ユーザーのリポジトリ情報が取得できた場合、Repoが返る")
    func getUserReposSucceeds() async throws {
        let repository = makeRepository(statusCode: 200, json: """
        [
          {
            "id": 1,
            "name": "Hello-World",
            "description": null,
            "language": "Swift",
            "stargazers_count": 80,
            "html_url": "https://github.com/octocat/Hello-World"
          }
        ]
        """)
        let repos = try await repository.fetchUserRepositories(username: "swift", page: 1)

        #expect(repos.count == 1)
        #expect(repos.first?.name == "Hello-World")
    }

    @Test("HTTPエラー時にNetworkErrorが伝播する")
    func errorPropagates() async {
        let repository = makeRepository(statusCode: 404, json: "")

        await #expect(throws: NetworkError.notFound) {
            _ = try await repository.searchUsers(keyword: "swift")
        }
    }
}
