import SwiftUI

struct UserDetailView: View {
    let username: String

    @State private var viewModel = UserDetailViewModel(repository: GitHubAPIRepository())

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
                    ForEach(repos) { repo in
                        RepoRow(repo: repo)
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
    }
}

#Preview {
    NavigationStack {
        UserDetailView(username: "octocat")
    }
}
