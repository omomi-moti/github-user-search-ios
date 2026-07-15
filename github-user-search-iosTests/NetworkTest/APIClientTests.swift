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

        #expect(response.items.first?.login == "swift")
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
        #expect(repos.first?.name == "swift")
    }

    @Test("404レスポンス時にNetworkError.notFoundがthrowされる")
    func fetchDataThrowsNotFound() async throws {
        let client = APIClient(session: MockURLSession(statusCode: 404, data: Data()))

        do {
            _ = try await client.fetchData(Endpoint.userDetail(username: "unknown").url)
            Issue.record("エラーがthrowされなかった")
        } catch NetworkError.notFound {
            // 期待通り
        } catch {
            Issue.record("期待と異なるエラー: \(error)")
        }
    }

    @Test("403レスポンス時にNetworkError.rateLimitedがthrowされる")
    func fetchDataThrowsRateLimited() async throws {
        let client = APIClient(session: MockURLSession(statusCode: 403, data: Data()))

        do {
            _ = try await client.fetchData(Endpoint.searchUsers(keyword: "x").url)
            Issue.record("エラーがthrowされなかった")
        } catch NetworkError.rateLimited {
            // 期待通り
        } catch {
            Issue.record("期待と異なるエラー: \(error)")
        }
    }

    @Test("500レスポンス時にNetworkError.serverErrorがthrowされる")
    func fetchDataThrowsServerError() async throws {
        let client = APIClient(session: MockURLSession(statusCode: 500, data: Data()))

        do {
            _ = try await client.fetchData(Endpoint.repos(username: "swiftlang").url)
            Issue.record("エラーがthrowされなかった")
        } catch NetworkError.serverError(let statusCode) {
            #expect(statusCode == 500)
        } catch {
            Issue.record("期待と異なるエラー: \(error)")
        }
    }

    @Test("422レスポンス時にNetworkError.validationErrorがthrowされる")
    func fetchDataThrowsValidationError() async throws {
        let client = APIClient(session: MockURLSession(statusCode: 422, data: Data()))

        do {
            _ = try await client.fetchData(Endpoint.searchUsers(keyword: "x").url)
            Issue.record("エラーがthrowされなかった")
        } catch NetworkError.validationError {
            // 期待通り
        } catch {
            Issue.record("期待と異なるエラー: \(error)")
        }
    }

    @Test("未知のステータスコード時にNetworkError.unknownがthrowされる")
    func fetchDataThrowsUnknown() async throws {
        let client = APIClient(session: MockURLSession(statusCode: 999, data: Data()))

        do {
            _ = try await client.fetchData(Endpoint.searchUsers(keyword: "x").url)
            Issue.record("エラーがthrowされなかった")
        } catch NetworkError.unknown(let statusCode) {
            #expect(statusCode == 999)
        } catch {
            Issue.record("期待と異なるエラー: \(error)")
        }
    }

    @Test("不正なJSONの場合NetworkError.decodingErrorがthrowされる")
    func decodeThrowsDecodingError() {
        let client = APIClient(session: MockURLSession(statusCode: 200, data: Data()))
        let invalidJSON = "not a json".data(using: .utf8)!

        do {
            let _: UserDetail = try client.decode(invalidJSON)
            Issue.record("エラーがthrowされなかった")
        } catch NetworkError.decodingError {
            // 期待通り
        } catch {
            Issue.record("期待と異なるエラー: \(error)")
        }
    }

    @Test("URLがnilの場合NetworkError.invalidURLがthrowされる")
    func fetchDataThrowsInvalidURLWhenURLIsNil() async throws {
        let client = APIClient(session: MockURLSession(statusCode: 200, data: Data()))

        do {
            _ = try await client.fetchData(nil)
            Issue.record("エラーがthrowされなかった")
        } catch NetworkError.invalidURL {
            // 期待通り
        } catch {
            Issue.record("期待と異なるエラー: \(error)")
        }
    }
}
