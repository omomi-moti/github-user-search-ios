import Testing
import Foundation
@testable import github_user_search_ios

@MainActor
struct AddServerFavoriteViewModelTests {

    @Test("登録に成功した場合、登録済みになりエラーは出ない")
    func addSucceeds() async {
        let viewModel = AddServerFavoriteViewModel(repository: MockFavoriteRepository())

        await viewModel.add(username: "swift", avatarURL: "https://example.com/a.png", name: nil)

        #expect(viewModel.isAdded)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isAdding)
    }

    @Test("登録済み(409)の場合、登録済みになり、そのことをエラーメッセージで伝える")
    func addConflict() async {
        let repository = MockFavoriteRepository(shouldFail: true, errorToThrow: .conflict)
        let viewModel = AddServerFavoriteViewModel(repository: repository)

        await viewModel.add(username: "omomi-moti", avatarURL: "", name: nil)

        #expect(viewModel.isAdded)
        #expect(viewModel.errorMessage == "すでに登録されています")
        #expect(!viewModel.isAdding)
    }

    @Test("サーバーエラーの場合、登録済みにならずエラーメッセージを出す")
    func addServerError() async {
        let repository = MockFavoriteRepository(shouldFail: true, errorToThrow: .serverError(statusCode: 500))
        let viewModel = AddServerFavoriteViewModel(repository: repository)

        await viewModel.add(username: "swift", avatarURL: "", name: nil)

        #expect(!viewModel.isAdded)
        #expect(viewModel.errorMessage == NetworkError.serverError(statusCode: 500).userMessage)
        #expect(!viewModel.isAdding)
    }
}
