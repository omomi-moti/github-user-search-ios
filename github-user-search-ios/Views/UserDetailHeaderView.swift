import SwiftUI
import SwiftData

struct UserDetailHeaderView: View {
    let detail: UserDetail

    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoriteUser]
    @State private var addServerViewModel: AddServerFavoriteViewModel

    init(detail: UserDetail, favoriteRepository: FavoriteRepository = FavoriteAPIRepository()) {
        self.detail = detail
        _addServerViewModel = State(initialValue: AddServerFavoriteViewModel(repository: favoriteRepository))
    }

    private var isFavorite: Bool {
        FavoriteViewModel(modelContext: modelContext).isFavorite(username: detail.login, favorites: favorites)
    }

    var body: some View {
        VStack(spacing: 12) {
            AvatarImage(url: detail.avatarURL, size: 96)

            Text(detail.name ?? detail.login)
                .font(.title2.bold())

            if let bio = detail.bio {
                Text(bio)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 24) {
                VStack {
                    Text("\(detail.followers)").font(.headline)
                    Text("Followers").font(.caption).foregroundStyle(.secondary)
                }
                VStack {
                    Text("\(detail.following)").font(.headline)
                    Text("Following").font(.caption).foregroundStyle(.secondary)
                }
            }

            Button {
                FavoriteViewModel(modelContext: modelContext).toggle(
                    username: detail.login,
                    avatarURL: detail.avatarURL,
                    name: detail.name,
                    favorites: favorites
                )
            } label: {
                Label(isFavorite ? "お気に入り解除" : "お気に入り登録", systemImage: isFavorite ? "star.fill" : "star")
            }
            .buttonStyle(.bordered)

            Button { //サーバーに登録する(端末のお気に入りとは別)
                Task {
                    await addServerViewModel.add(username: detail.login, avatarURL: detail.avatarURL, name: detail.name)
                }
            } label: {
                if addServerViewModel.isAdding {
                    ProgressView()
                } else {
                    Label(addServerViewModel.isAdded ? "サーバーに登録済み" : "サーバーに登録", systemImage: addServerViewModel.isAdded ? "checkmark.icloud" : "icloud.and.arrow.up")
                }
            }
            .buttonStyle(.bordered)
            .disabled(addServerViewModel.isAdding || addServerViewModel.isAdded)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .alert("サーバーに登録できませんでした", isPresented: Binding(
            get: { addServerViewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented { addServerViewModel.errorMessage = nil } //アラートを閉じたらメッセージを消す
            }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(addServerViewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    UserDetailHeaderView(detail: UserDetail(login: "octocat", name: "The Octocat", bio: "GitHub mascot", followers: 100, following: 9, avatarURL: "https://avatars.githubusercontent.com/u/1"), favoriteRepository: MockFavoriteRepository())
        .modelContainer(for: FavoriteUser.self, inMemory: true)
}
