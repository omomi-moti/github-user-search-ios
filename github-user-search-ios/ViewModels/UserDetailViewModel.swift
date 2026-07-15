import Foundation
import Observation

@Observable
@MainActor
class UserDetailViewModel{
    var detailState : ViewState<UserDetail> = .idle
    var repoState : ViewState<[Repo]> = .idle

    private let repository : GitHubRepository
        
    init(repository : GitHubRepository){
        self.repository = repository
    }
    
    func load(username : String) async {
        detailState = .loading
        repoState = .loading
        
        async let detailResult = repository.fetchUserDetail(username: username)
        async let repoResult = repository.fetchUserRepositories(username: username)
        
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
            let repos = try await repoResult
            guard !Task.isCancelled else { return }
            repoState = .loaded(repos)
        }
        catch{
            guard !Task.isCancelled else { return }
            let message = (error as? NetworkError)?.userMessage ?? "リポジトリ一覧の取得に失敗しました"
            repoState = .error(message)
        }
        
    }
}
