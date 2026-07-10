import Foundation

struct SearchUser: Codable {
    let id : Int
    let login : String
    let avatarURL : String
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarURL = "avatar_url"
    }
}
