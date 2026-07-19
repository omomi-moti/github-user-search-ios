import SwiftUI
import SwiftData

struct FavoriteListView: View {
    @Query(sort: \FavoriteUser.savedAt, order: .reverse) private var favorites: [FavoriteUser]

    var body: some View {
        Group {
            if favorites.isEmpty {
                ContentUnavailableView("お気に入りはまだありません", systemImage: "star")
            } else {
                List(favorites) { favorite in
                    NavigationLink(value: favorite.username) {
                        HStack(spacing: 12) {
                            AvatarImage(url: favorite.avatarURL)
                            Text(favorite.name ?? favorite.username)
                        }
                    }
                }
            }
        }
        .navigationTitle("お気に入り")
        .navigationDestination(for: String.self) { username in
            UserDetailView(username: username)
        }
    }
}

#Preview {
    NavigationStack {
        FavoriteListView()
    }
    .modelContainer(for: FavoriteUser.self, inMemory: true)
}

