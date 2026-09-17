import Foundation
import Observation

@Observable
@MainActor
class ServerFavoriteViewModel {
    var state: ViewState<[ServerFavorite]> = .idle
    var deleteErrorMessage: String? //nil以外ならアラートを出す(一覧のstateはエラーにしない)
    
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
    func delete(username: String) async {
        do {
            try await repository.deleteFavorite(username: username)
            removeFromList(username: username)
        } catch NetworkError.notFound {
            removeFromList(username: username) //サーバーにはもういないので、削除できたものとして扱う
        } catch {
            deleteErrorMessage = (error as? NetworkError)?.userMessage ?? "サーバーからの削除に失敗しました"
        }
    }

    private func removeFromList(username: String) {
        guard case .loaded(var favorites) = state else { return }
        favorites.removeAll { $0.username == username }
        state = .loaded(favorites)
    }
}
