import SwiftUI
import SwiftData

struct FavoriteListView: View {
    @Query(sort: \FavoriteUser.savedAt, order: .reverse) private var favorites: [FavoriteUser]
    @State private var serverViewModel: ServerFavoriteViewModel

    init(repository: FavoriteRepository = FavoriteAPIRepository()) {
        _serverViewModel = State(initialValue: ServerFavoriteViewModel(repository: repository))
    }

    var body: some View {
        List {
            Section("この端末") {
                if favorites.isEmpty {
                    ContentUnavailableView("お気に入りはまだありません", systemImage: "star")
                } else {
                    ForEach(favorites) { favorite in
                        NavigationLink(value: favorite.username) {
                            HStack(spacing: 12) {
                                AvatarImage(url: favorite.avatarURL)
                                Text(favorite.name ?? favorite.username)
                            }
                        }
                    }
                }
            }

            Section("サーバー") { //サーバーのお気に入りは読み取り専用で表示する
                switch serverViewModel.state {
                case .idle, .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                case .loaded(let serverFavorites):
                    if serverFavorites.isEmpty {
                        ContentUnavailableView("サーバーにお気に入りはありません", systemImage: "server.rack")
                    } else {
                        ForEach(serverFavorites) { favorite in
                            HStack(spacing: 12) {
                                AvatarImage(url: favorite.avatarURL)
                                Text(favorite.name ?? favorite.username)
                            }
                        }
                    }
                case .error(let message):
                    RetryView(message: message, retryAction: {
                        Task { await serverViewModel.load() }
                    })
                }
            }
        }
        .navigationTitle("お気に入り")
        .navigationDestination(for: String.self) { username in
            UserDetailView(username: username)
        }
        .task {
            await serverViewModel.load()
        }
    }
}

#Preview {
    NavigationStack {
        FavoriteListView(repository: MockFavoriteRepository())
    }
    .modelContainer(for: FavoriteUser.self, inMemory: true)
}
