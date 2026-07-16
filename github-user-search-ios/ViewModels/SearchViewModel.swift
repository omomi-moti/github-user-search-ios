import Foundation
import Observation

@Observable
@MainActor
class SearchViewModel {
    var keyword: String = ""
    var state: ViewState<[SearchUser]> = .idle

    private let repository: GitHubRepository
    private let historyStore: SearchHistoryStore

    init(repository: GitHubRepository, historyStore: SearchHistoryStore = SearchHistoryStore()) {
        self.repository = repository
        self.historyStore = historyStore
    }

    var recentSearches: [String] {
        Array(historyStore.load().prefix(5))
    }

    func search() async {
        guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            state = .idle
            return
        }

        try? await Task.sleep(for: .milliseconds(300))
        guard !Task.isCancelled else { return }

        state = .loading
        do {
            let users = try await repository.searchUsers(keyword: keyword)
            guard !Task.isCancelled else { return }
            state = .loaded(users)
            historyStore.add(keyword)
        } catch {
            guard !Task.isCancelled else { return }
            let message = (error as? NetworkError)?.userMessage ?? "検索に失敗しました"
            state = .error(message)
        }
    }
}
