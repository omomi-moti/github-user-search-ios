import Testing
import Foundation
@testable import github_user_search_ios

@MainActor
struct SearchViewModelTests {
    @Test("検索成功時にstateがloadedになる")
    func searchSucceeds() async throws{
        let repository = MockGitHubRepository(shouldFail: false)
        let viewModel = SearchViewModel(repository: repository)
        
        viewModel.keyword = "swift"
        viewModel.onKeywordChanged()
        
        try await Task.sleep(for: .milliseconds(500))
        if case .loaded(let users) = viewModel.state{
            #expect(users.first?.login == "swift")
        }
        else{
            Issue.record("stateがloadedになっていない")
        }
    }
    @Test("検索失敗時にstateがerrorになる")
    func searchFails() async throws{
        let repository = MockGitHubRepository(shouldFail: true)
        let viewModel = SearchViewModel(repository: repository)
        
        viewModel.keyword = "swift"
        viewModel.onKeywordChanged()
        
        try await Task.sleep(for: .milliseconds(500))
        
        if case .error = viewModel.state{
            //stateがerrorならOK
        }
        else{
            Issue.record("stateがerrorになっていない")
        }
    }
    
    @Test("キーワードが空の場合stateがidleになる")
    func emptyKeywordSetsIdle(){
        let repository = MockGitHubRepository(shouldFail: false)
        let viewModel = SearchViewModel(repository: repository)
        
        viewModel.keyword = ""
        viewModel.onKeywordChanged()
        
        if case .idle = viewModel.state {
            // stateがidleならOK
        } else {
            Issue.record("stateがidleになっていない")
        }
    }
}
