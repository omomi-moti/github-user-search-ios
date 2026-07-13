import SwiftUI
import Kingfisher

struct SearchUserRow: View {
    let user: SearchUser

    var body: some View {
        HStack(spacing: 12) {
            KFImage(URL(string: user.avatarURL))
                .resizable()
                .placeholder { Color.gray.opacity(0.2) }
                .frame(width: 44, height: 44)
                .clipShape(Circle())

            Text(user.login)
        }
    }
}

#Preview {
    SearchUserRow(user: SearchUser(id: 1, login: "octocat", avatarURL: "https://avatars.githubusercontent.com/u/1"))
}
