import Testing
import Foundation
@testable import github_user_search_ios

@MainActor
struct UserDetailViewModelTests{
    
    @Test("詳細取得成功時にdetailStateがloadedになる")
    func fetchDetailSuccess() async throws {
        let repository = MockGitHubRepository(shouldFail: false)
        let viewModel = UserDetailViewModel(repository:repository)
        
        await viewModel.load(username : "swift")
        
        if case .loaded(let detail) = viewModel.detailState {
            #expect(detail.login == "swift")
        }
        else{
            Issue.record("detailStateがloadedになっていない")
        }
    }
    
    @Test("リポジトリ一覧取得成功時にreposStateがloadedになる")
    func fetchReposSuccess() async throws {
        let repository = MockGitHubRepository(shouldFail: false)
        let viewModel = UserDetailViewModel(repository:repository)
        
        await viewModel.load(username : "swift")
        
        if case .loaded(let repos) = viewModel.repoState {
            #expect(repos.first?.name == "Hello-World")
        }
        else{
            Issue.record("reposStateがloadedになっていない")
        }
    }
    
    @Test("取得失敗時にdetailStateとreposStateが両方errorになる")
    func loadFail() async throws {
        let repository = MockGitHubRepository(shouldFail: true)
        let viewModel = UserDetailViewModel(repository: repository)

        await viewModel.load(username: "swift")

        if case .error = viewModel.detailState{
            // detailStateがerrorならOK
        }
        else{
            Issue.record("reposStateがerrorになっていない")
        }
        if case .error = viewModel.repoState {
            // repoStateがerrorならOK
        } else {
            Issue.record("reposStateがerrorになっていない")
        }
    }

    @Test("detailState取得失敗時にNetworkErrorの種類に応じたメッセージが返る")
    func detailErrorHasSpecificMessage() async throws {
        let repository = MockGitHubRepository(shouldFail: true, errorToThrow: .notFound)
        let viewModel = UserDetailViewModel(repository: repository)

        await viewModel.load(username: "swift")

        if case .error(let message) = viewModel.detailState {
            #expect(message.contains("見つかりませんでした"))
        } else {
            Issue.record("detailStateがerrorになっていない")
        }
    }

    @Test("repoState取得失敗時にNetworkErrorの種類に応じたメッセージが返る")
    func repoErrorHasSpecificMessage() async throws {
        let repository = MockGitHubRepository(shouldFail: true, errorToThrow: .rateLimited)
        let viewModel = UserDetailViewModel(repository: repository)

        await viewModel.load(username: "swift")

        if case .error(let message) = viewModel.repoState {
            #expect(message.contains("アクセス制限"))
        } else {
            Issue.record("repoStateがerrorになっていない")
        }
    }
}
