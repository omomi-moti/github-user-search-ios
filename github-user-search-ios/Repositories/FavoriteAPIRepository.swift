import Foundation

struct FavoriteAPIRepository: FavoriteRepository {

    private let client: APIClient
    private let server: APIServer

    init(client: APIClient = APIClient(), server: APIServer = .local) {
        self.client = client
        self.server = server
    }

    func fetchFavorites() async throws -> [ServerFavorite] {
        let url = Endpoint.favorites.url(on: server)
        let data = try await client.fetchData(url)
        return try client.decode(data)
    }

    func addFavorite(username: String, avatarURL: String, name: String?) async throws -> ServerFavorite {
        let url = Endpoint.favorites.url(on: server)
        let request = ServerFavoriteRequest(username: username, avatarURL: avatarURL, name: name)
        let body = try JSONEncoder().encode(request)
        let data = try await client.fetchData(url, method: "POST", body: body)
        return try client.decode(data) //サーバーは追加した1件を返す
    }
}
