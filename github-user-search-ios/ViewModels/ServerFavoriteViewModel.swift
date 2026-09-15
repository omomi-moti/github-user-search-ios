import Foundation
import Observation

@Observable
@MainActor
class ServerFavoriteViewModel {
    var state: ViewState<[ServerFavorite]> = .idle

    private let repository: FavoriteRepository

    init(repository: FavoriteRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            let favorites = try await repository.fetchFavorites()
            guard !Task.isCancelled else { return }
            state = .loaded(favorites)
        } catch {
            guard !Task.isCancelled else { return }
            let message = (error as? NetworkError)?.userMessage ?? "サーバーのお気に入りの取得に失敗しました"
            state = .error(message)
        }
    }
}
