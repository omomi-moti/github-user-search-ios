import Testing
import Foundation
@testable import github_user_search_ios

@MainActor
struct ServerFavoriteViewModelTests {

    private func makeViewModel(repository: MockFavoriteRepository) -> ServerFavoriteViewModel {
        let viewModel = ServerFavoriteViewModel(repository: repository)
        viewModel.state = .loaded([
            ServerFavorite(username: "omomi-moti", avatarURL: "", name: "鈴木聖也", savedAt: Date(timeIntervalSince1970: 0)),
            ServerFavorite(username: "onevcat", avatarURL: "", name: nil, savedAt: Date(timeIntervalSince1970: 0))
        ])
        return viewModel
    }

    private func usernames(in viewModel: ServerFavoriteViewModel) -> [String] {
        guard case .loaded(let favorites) = viewModel.state else { return [] }
        return favorites.map(\.username)
    }

    @Test("削除に成功した場合、一覧から消えてエラーは出ない")
    func deleteSucceeds() async {
        let viewModel = makeViewModel(repository: MockFavoriteRepository())

        await viewModel.delete(username: "omomi-moti")

        #expect(usernames(in: viewModel) == ["onevcat"])
        #expect(viewModel.deleteErrorMessage == nil)
    }

    @Test("すでに削除されていた場合(404)、削除できたものとして一覧から消える")
    func deleteNotFound() async {
        let viewModel = makeViewModel(repository: MockFavoriteRepository(shouldFail: true, errorToThrow: .notFound))

        await viewModel.delete(username: "omomi-moti")

        #expect(usernames(in: viewModel) == ["onevcat"])
        #expect(viewModel.deleteErrorMessage == nil)
    }

    @Test("サーバーエラーの場合、一覧はそのままでエラーメッセージを出す")
    func deleteServerError() async {
        let viewModel = makeViewModel(repository: MockFavoriteRepository(shouldFail: true, errorToThrow: .serverError(statusCode: 500)))

        await viewModel.delete(username: "omomi-moti")

        #expect(usernames(in: viewModel) == ["omomi-moti", "onevcat"])
        #expect(viewModel.deleteErrorMessage == NetworkError.serverError(statusCode: 500).userMessage)
    }
}
