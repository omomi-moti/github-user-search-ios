import Foundation

struct MockFavoriteRepository: FavoriteRepository {
    var shouldFail = false
    var errorToThrow: NetworkError = .serverError(statusCode: 500)

    func fetchFavorites() async throws -> [ServerFavorite] {
        if shouldFail {
            throw errorToThrow
        }
        return [
            ServerFavorite(username: "omomi-moti", avatarURL: "https://avatars.githubusercontent.com/u/200570868?v=4", name: "鈴木聖也", savedAt: Date(timeIntervalSince1970: 0)),
            ServerFavorite(username: "onevcat", avatarURL: "https://avatars.githubusercontent.com/u/1019875?v=4", name: nil, savedAt: Date(timeIntervalSince1970: 0))
        ]
    }

    func addFavorite(username: String, avatarURL: String, name: String?) async throws -> ServerFavorite {
        if shouldFail {
            throw errorToThrow
        }
        return ServerFavorite(username: username, avatarURL: avatarURL, name: name, savedAt: Date(timeIntervalSince1970: 0))
    }
}
