import SwiftUI

private struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct UserDetailView: View {
    let username: String
    
    @State private var viewModel: UserDetailViewModel
    @State private var selectedURL: IdentifiableURL?
    
    init(username: String, repository: GitHubRepository = GitHubAPIRepository()) {
        self.username = username
        _viewModel = State(initialValue: UserDetailViewModel(repository: repository))
    }
    
    var body: some View {
        List {
            Section {
                switch viewModel.detailState {
                case .idle, .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                case .loaded(let detail):
                    UserDetailHeaderView(detail: detail)
                case .error(let message):
                    RetryView(message: message, retryAction: {
                        Task { await viewModel.load(username: username) }
                    })
                }
            }
            .listRowSeparator(.hidden)
            
            Section("Repositories") {
                switch viewModel.repoState {
                case .idle, .loading:
                    ProgressView()
                case .loaded(let repos):
                    if repos.isEmpty {
                        ContentUnavailableView("リポジトリがありません", systemImage: "folder")
                    } else {
                        ForEach(repos) { repo in
                            RepoRow(repo: repo)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if let url = URL(string: repo.htmlURL) {
                                        selectedURL = IdentifiableURL(url: url)
                                    }
                                }
                                .onAppear {
                                    if repo.id == repos.last?.id {
                                        Task { await viewModel.loadMoreRepos(username: username) }
                                    }
                                }
                        }
                        if viewModel.isLoadingMore {
                            ProgressView()
                        }
                    }
                case .error(let message):
                    RetryView(message: message, retryAction: {
                        Task { await viewModel.load(username: username) }
                    })
                }
            }
        }
        .navigationTitle(username)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load(username: username)
        }
        .sheet(item: $selectedURL) { item in
            SafariView(url: item.url)
        }
    }
}

#Preview {
    NavigationStack {
        UserDetailView(username: "octocat", repository: MockGitHubRepository(shouldFail: false))
    }
}
