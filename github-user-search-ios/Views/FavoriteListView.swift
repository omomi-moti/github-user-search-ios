import SwiftUI
import SwiftData
import Kingfisher

struct FavoriteListView: View {
    @Query(sort: \FavoriteUser.savedAt, order: .reverse) private var favorites: [FavoriteUser]

    var body: some View {
        List(favorites) { favorite in
            NavigationLink(value: favorite.username) {
                HStack(spacing: 12) {
                    KFImage(URL(string: favorite.avatarURL))
                        .resizable()
                        .placeholder { Color.gray.opacity(0.2) }
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())

                    Text(favorite.name ?? favorite.username)
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
