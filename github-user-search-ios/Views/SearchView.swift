import SwiftUI

struct SearchView: View {
    @State private var viewModel: SearchViewModel

    init(repository: GitHubRepository = GitHubAPIRepository()) {
        _viewModel = State(initialValue: SearchViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("ユーザー検索")
                .searchable(text: $viewModel.keyword, prompt: "ユーザー名を入力")
                .onChange(of: viewModel.keyword) {
                    viewModel.onKeywordChanged()
                }
                .navigationDestination(for: String.self) { username in
                    UserDetailView(username: username)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            if viewModel.recentSearches.isEmpty {
                ContentUnavailableView("ユーザー名を入力してください", systemImage: "magnifyingglass")
            } else {
                List {
                    Section("最近の検索") {
                        ForEach(viewModel.recentSearches, id: \.self) { keyword in
                            Button(keyword) {
                                viewModel.keyword = keyword
                                viewModel.onKeywordChanged()
                            }
                        }
                    }
                }
            }
        case .loading:
            ProgressView()
        case .loaded(let users):
            List(users, id: \.id) { user in
                NavigationLink(value: user.login) {
                    SearchUserRow(user: user)
                }
            }
        case .error(let message):
            RetryView(message: message, retryAction: {
                viewModel.onKeywordChanged()
            })
        }
    }
}

#Preview {
    SearchView(repository: MockGitHubRepository(shouldFail: false))
}
