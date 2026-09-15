import Foundation

protocol FavoriteRepository {
    func fetchFavorites() async throws -> [ServerFavorite]
}
