import Foundation
import Observation

@Observable
@MainActor
class AddServerFavoriteViewModel { //ユーザー詳細画面の「サーバーに登録」ボタン用(一覧表示のServerFavoriteViewModelとは別)
    var isAdding = false //登録中はボタンを押せなくする
    var isAdded = false //登録済みならボタンを「サーバーに登録済み」にする
    var errorMessage: String? //nil以外ならアラートを出す

    private let repository: FavoriteRepository

    init(repository: FavoriteRepository) {
        self.repository = repository
    }

    func add(username: String, avatarURL: String, name: String?) async {
        guard !isAdding else { return }
        isAdding = true
        defer { isAdding = false }

        do {
            _ = try await repository.addFavorite(username: username, avatarURL: avatarURL, name: name)
            isAdded = true
        } catch NetworkError.conflict {
            isAdded = true //サーバーにはすでに登録されているので、登録済みとして扱う
            errorMessage = NetworkError.conflict.userMessage
        } catch {
            errorMessage = (error as? NetworkError)?.userMessage ?? "サーバーへの登録に失敗しました"
        }
    }
}
