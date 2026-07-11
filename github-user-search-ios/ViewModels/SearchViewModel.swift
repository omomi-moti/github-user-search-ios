import Foundation
import Observation

@Observable
@MainActor
class SearchViewModel{
    var keyword : String = ""
    var state : ViewState<[SearchUser]> = .idle
    
    private let repository : GitHubRepository
    private var searchTask : Task<Void, Never>? //<このTaskが完了した時に、何か値を返すか,このTaskがエラーを投げる可能性があるか>
    
    init(repository : GitHubRepository){
        self.repository = repository
    }
    
    func onKeywordChanged(){
        searchTask?.cancel()
        
        guard !keyword.isEmpty else{ //キーワードの入力がない場合は呼ばれても何もしない
            state = .idle
            return
        }
        
        searchTask = Task{
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else{ return }
            await search()
        }
        
    }
    private func search() async{
        state = .loading
        do{
            let users = try await repository.searchUsers(keyword: keyword)
            guard !Task.isCancelled else{ return }
            state = .loaded(users)
            
        }
        catch{
            guard !Task.isCancelled else{ return }
            state = .error("検索に失敗しました")
        }
    }
}

