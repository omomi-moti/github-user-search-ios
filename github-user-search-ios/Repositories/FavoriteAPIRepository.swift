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
}
