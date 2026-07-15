import Foundation
import Testing
@testable import github_user_search_ios

struct APIClientTests {

    @Test("200レスポンスからSearchUsersResponseにデコードできる")
    func fetchSearchUsersSuccess() async throws {
        let json = """
        {
          "total_count": 1,
          "incomplete_results": false,
          "items": [
            {"id": 1, "login": "swift", "avatar_url": "https://example.com/a.png"}
          ]
        }
        """.data(using: .utf8)!
        let client = APIClient(session: MockURLSession(statusCode: 200, data: json))
        let url = Endpoint.searchUsers(keyword: "swift").url

        let data = try await client.fetchData(url)
        let response: SearchUsersResponse = try client.decode(data)

        let firstItem = try #require(response.items.first)
        #expect(firstItem.login == "swift")
    }

    @Test("200レスポンスからUserDetailにデコードできる")
    func fetchDetailUser() async throws {
        let json = """
        {
          "login": "swiftlang",
          "name": "The Swift Programming Language",
          "bio": null,
          "followers": 100,
          "following": 0,
          "avatar_url": "https://example.com/swift.png"
        }
        """.data(using: .utf8)!
        let client = APIClient(session: MockURLSession(statusCode: 200, data: json))
        let url = Endpoint.userDetail(username: "swiftlang").url

        let data = try await client.fetchData(url)
        let detail: UserDetail = try client.decode(data)

        #expect(detail.login == "swiftlang")
        #expect(detail.avatarURL.isEmpty == false)
    }

    @Test("200レスポンスから[Repo]にデコードできる")
    func fetchDetailUserRepos() async throws {
        let json = """
        [
          {
            "id": 1,
            "name": "swift",
            "description": null,
            "language": "C++",
            "stargazers_count": 80000,
            "html_url": "https://github.com/swiftlang/swift"
          }
        ]
        """.data(using: .utf8)!
        let client = APIClient(session: MockURLSession(statusCode: 200, data: json))
        let url = Endpoint.repos(username: "swiftlang").url

        let data = try await client.fetchData(url)
        let repos: [Repo] = try client.decode(data)

        #expect(!repos.isEmpty)
        let firstRepo = try #require(repos.first)
        #expect(firstRepo.name == "swift")
    }

    @Test(
        "ステータスコードに応じたNetworkErrorが正しくthrowされる",
        arguments: [
            (403, NetworkError.rateLimited),
            (404, NetworkError.notFound),
            (422, NetworkError.validationError),
            (500, NetworkError.serverError(statusCode: 500)),
            (999, NetworkError.unknown(statusCode: 999))
        ]
    )
    func fetchDataThrowsCorrectErrorForStatusCode(statusCode: Int, expectedError: NetworkError) async {
        let client = APIClient(session: MockURLSession(statusCode: statusCode, data: Data()))
        let url = Endpoint.searchUsers(keyword: "x").url

        await #expect(throws: expectedError) {
            _ = try await client.fetchData(url)
        }
    }

    @Test("不正なJSONの場合NetworkError.decodingErrorがthrowされる")
    func decodeThrowsDecodingError() {
        let client = APIClient(session: MockURLSession(statusCode: 200, data: Data()))
        let invalidJSON = "not a json".data(using: .utf8)!

        #expect(throws: NetworkError.decodingError) {
            let _: UserDetail = try client.decode(invalidJSON)
        }
    }

    @Test("URLがnilの場合NetworkError.invalidURLがthrowされる")
    func fetchDataThrowsInvalidURLWhenURLIsNil() async {
        let client = APIClient(session: MockURLSession(statusCode: 200, data: Data()))

        await #expect(throws: NetworkError.invalidURL) {
            _ = try await client.fetchData(nil)
        }
    }
}
