import Foundation

protocol FavoriteRepository {
    func fetchFavorites() async throws -> [ServerFavorite]
    func addFavorite(username: String, avatarURL: String, name: String?) async throws -> ServerFavorite
    func deleteFavorite(username: String) async throws
}
