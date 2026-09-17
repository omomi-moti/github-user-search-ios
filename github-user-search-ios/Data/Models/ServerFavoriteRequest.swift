import Foundation

struct ServerFavoriteRequest: Encodable { //サーバーにお気に入りを登録するときに送る内容(savedAtはサーバーが決めるので送らない)
    let username: String
    let avatarURL: String
    let name: String? //nilのときはキーごと送らず、サーバー側ではnullになる
}
