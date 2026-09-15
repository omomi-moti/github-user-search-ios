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
}
