import Testing
import Foundation
@testable import github_user_search_ios

struct FavoriteRepositoryTests {

    private func makeRepository(statusCode: Int, json: String) -> FavoriteAPIRepository {
        let data = json.data(using: .utf8)!
        let client = APIClient(session: MockURLSession(statusCode: statusCode, data: data))
        return FavoriteAPIRepository(client: client)
    }

    //github-user-search-api#12 の後に curl http://localhost:8080/favorites で取得した実際のレスポンス
    private let favoritesJSON = """
    [{"username":"omomi-moti","avatarURL":"https://avatars.githubusercontent.com/u/200570868?v=4","name":"鈴木聖也","savedAt":"2026-09-13T10:00:00Z"},{"username":"onevcat","avatarURL":"https://avatars.githubusercontent.com/u/1019875?v=4","name":null,"savedAt":"2026-09-13T11:30:00Z"}]
    """

    @Test("お気に入り一覧の取得に成功した場合、ServerFavoriteの配列が返る")
    func fetchFavoritesSucceeds() async throws {
        let repository = makeRepository(statusCode: 200, json: favoritesJSON)

        let favorites = try await repository.fetchFavorites()

        #expect(favorites.count == 2)
        #expect(favorites.map(\.username) == ["omomi-moti", "onevcat"])
    }

    @Test("nameがnullの場合、nilとしてデコードされる")
    func nullNameDecodesAsNil() async throws {
        let repository = makeRepository(statusCode: 200, json: favoritesJSON)

        let favorites = try await repository.fetchFavorites()

        #expect(favorites[0].name == "鈴木聖也")
        #expect(favorites[1].name == nil)
    }

    @Test("savedAtがISO8601の日時としてDateにデコードされる")
    func savedAtDecodesAsDate() async throws {
        let repository = makeRepository(statusCode: 200, json: favoritesJSON)

        let favorites = try await repository.fetchFavorites()

        let expected = try #require(ISO8601DateFormatter().date(from: "2026-09-13T10:00:00Z"))
        #expect(favorites[0].savedAt == expected)
    }

    @Test("HTTPエラー時にNetworkErrorが伝播する")
    func errorPropagates() async {
        let repository = makeRepository(statusCode: 500, json: "")

        await #expect(throws: NetworkError.serverError(statusCode: 500)) {
            _ = try await repository.fetchFavorites()
        }
    }

    //github-user-search-api#14 の POST /favorites が返した実際のレスポンス（httptestで {"username":"swift"} をPOSTして取得）
    private let createdJSON = """
    {"username":"swift","avatarURL":"","name":null,"savedAt":"2026-09-17T02:24:07Z"}
    """

    @Test("お気に入りの登録に成功した場合、追加された1件が返る")
    func addFavoriteSucceeds() async throws {
        let repository = makeRepository(statusCode: 201, json: createdJSON)

        let favorite = try await repository.addFavorite(username: "swift", avatarURL: "", name: nil)

        #expect(favorite.username == "swift")
        #expect(favorite.name == nil)
    }

    @Test("登録済みの場合、NetworkError.conflictになる")
    func addFavoriteConflict() async {
        let repository = makeRepository(statusCode: 409, json: "favorite already exists")

        await #expect(throws: NetworkError.conflict) {
            _ = try await repository.addFavorite(username: "omomi-moti", avatarURL: "", name: nil)
        }
    }

    @Test("登録するとき、POSTでJSONのボディを送る")
    func addFavoriteSendsPostWithJSONBody() async throws {
        let session = RecordingURLSession(statusCode: 201, data: createdJSON.data(using: .utf8)!)
        let repository = FavoriteAPIRepository(client: APIClient(session: session))

        _ = try await repository.addFavorite(username: "swift", avatarURL: "https://example.com/a.png", name: "The Swift")

        let request = try #require(session.lastRequest)
        #expect(request.httpMethod == "POST")
        #expect(request.url?.absoluteString == "http://localhost:8080/favorites")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

        let body = try #require(request.httpBody)
        let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: String])
        #expect(json == ["username": "swift", "avatarURL": "https://example.com/a.png", "name": "The Swift"])
    }
}
