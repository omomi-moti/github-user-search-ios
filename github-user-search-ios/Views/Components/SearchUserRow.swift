import SwiftUI

struct SearchUserRow: View {
    let user: SearchUser

    var body: some View {
        HStack(spacing: 12) {
            AvatarImage(url: user.avatarURL)
            Text(user.login)
        }
    }
}

#Preview {
    SearchUserRow(user: SearchUser(id: 1, login: "octocat", avatarURL: "https://avatars.githubusercontent.com/u/1"))
}
