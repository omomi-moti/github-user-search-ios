import Foundation

struct ServerFavorite: Codable, Identifiable { //サーバーのお気に入りのレスポンス用(SwiftDataのFavoriteUserとは別)
    let username: String
    let avatarURL: String
    let name: String? //名前が未設定の場合はnullで返る
    let savedAt: Date

    var id: String { username }
}
