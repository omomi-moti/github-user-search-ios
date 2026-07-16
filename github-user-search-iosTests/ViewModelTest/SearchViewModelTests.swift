import Testing
import Foundation
@testable import github_user_search_ios

@MainActor
struct SearchViewModelTests {
    private func makeIsolatedHistoryStore() -> SearchHistoryStore {
        let suiteName = "test_\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        return SearchHistoryStore(userDefaults: userDefaults)
    }

    @Test("検索成功時にstateがloadedになる")
    func searchSucceeds() async throws {
        let repository = MockGitHubRepository(shouldFail: false)
        let viewModel = SearchViewModel(repository: repository, historyStore: makeIsolatedHistoryStore())

        viewModel.keyword = "swift"
        await viewModel.search()

        if case .loaded(let users) = viewModel.state {
            #expect(users.first?.login == "swift")
        } else {
            Issue.record("stateがloadedになっていない")
        }
    }

    @Test("検索失敗時にstateがerrorになる")
    func searchFails() async throws {
        let repository = MockGitHubRepository(shouldFail: true)
        let viewModel = SearchViewModel(repository: repository, historyStore: makeIsolatedHistoryStore())

        viewModel.keyword = "swift"
        await viewModel.search()

        if case .error = viewModel.state {
            // stateがerrorならOK
        } else {
            Issue.record("stateがerrorになっていない")
        }
    }

    @Test("キーワードが空の場合stateがidleになる")
    func emptyKeywordSetsIdle() async {
        let repository = MockGitHubRepository(shouldFail: false)
        let viewModel = SearchViewModel(repository: repository, historyStore: makeIsolatedHistoryStore())

        viewModel.keyword = ""
        await viewModel.search()

        if case .idle = viewModel.state {
            // stateがidleならOK
        } else {
            Issue.record("stateがidleになっていない")
        }
    }

    @Test("rateLimitedエラー時にメッセージが「アクセス制限」を含む")
    func rateLimitedErrorHasSpecificMessage() async throws {
        let repository = MockGitHubRepository(shouldFail: true, errorToThrow: .rateLimited)
        let viewModel = SearchViewModel(repository: repository, historyStore: makeIsolatedHistoryStore())

        viewModel.keyword = "swift"
        await viewModel.search()

        if case .error(let message) = viewModel.state {
            #expect(message.contains("アクセス制限"))
        } else {
            Issue.record("stateがerrorになっていない")
        }
    }

    @Test("notFoundエラー時にメッセージが「見つかりませんでした」を含む")
    func notFoundErrorHasSpecificMessage() async throws {
        let repository = MockGitHubRepository(shouldFail: true, errorToThrow: .notFound)
        let viewModel = SearchViewModel(repository: repository, historyStore: makeIsolatedHistoryStore())

        viewModel.keyword = "swift"
        await viewModel.search()

        if case .error(let message) = viewModel.state {
            #expect(message.contains("見つかりませんでした"))
        } else {
            Issue.record("stateがerrorになっていない")
        }
    }
}
