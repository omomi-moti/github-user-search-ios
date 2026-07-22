import Foundation
import Observation

@Observable
@MainActor
class UserDetailViewModel{
    var detailState : ViewState<UserDetail> = .idle
    var repoState : ViewState<[Repo]> = .idle
    var isLoadingMore = false
    
    private var currentPage = 1
    private var hasMorePages = true
    private var repos : [Repo] = []
    
    
    private let repository : GitHubRepository
    
    init(repository : GitHubRepository){
        self.repository = repository
    }
    
    func load(username : String) async {
        detailState = .loading
        repoState = .loading
        
        currentPage = 1
        hasMorePages = true
        repos = []
        
        async let detailResult = repository.fetchUserDetail(username: username)
        async let repoResult = repository.fetchUserRepositories(username: username,page : 1)
        
        do{
            let detail = try await detailResult
            guard !Task.isCancelled else { return }
            detailState = .loaded(detail)
        }
        catch{
            guard !Task.isCancelled else { return }
            let message = (error as? NetworkError)?.userMessage ?? "詳細情報の取得に失敗しました"
            detailState = .error(message)
        }
        
        do{
            let newRepos = try await repoResult
            guard !Task.isCancelled else { return }
            repos = newRepos
            repoState = .loaded(repos)
            if newRepos.count < 30 { hasMorePages = false }
        }
        catch{
            guard !Task.isCancelled else { return }
            let message = (error as? NetworkError)?.userMessage ?? "リポジトリ一覧の取得に失敗しました"
            repoState = .error(message)
        }
        
    }
    func loadMoreRepos(username : String) async {
        guard hasMorePages , !isLoadingMore else { return }
        isLoadingMore = true
        currentPage += 1
        defer { isLoadingMore = false }

        do{
            let newRepos = try await repository.fetchUserRepositories(username: username, page: currentPage)
            guard !Task.isCancelled else { return }
            repos.append(contentsOf: newRepos)
            repoState = .loaded(repos)
            if newRepos.count < 30 { hasMorePages = false }
        }
        catch {
            guard !Task.isCancelled else { return }
            currentPage -= 1
        }
    }
}
