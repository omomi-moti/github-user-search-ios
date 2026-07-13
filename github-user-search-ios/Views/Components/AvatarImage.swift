import SwiftUI
import Kingfisher

struct AvatarImage: View {
    let url: String
    var size: CGFloat = 44

    var body: some View {
        KFImage(URL(string: url))
            .resizable()
            .placeholder { Color.gray.opacity(0.2) }
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

#Preview {
    AvatarImage(url: "https://avatars.githubusercontent.com/u/1", size: 96)
}
