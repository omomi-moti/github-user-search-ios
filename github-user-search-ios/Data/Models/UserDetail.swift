import Foundation

struct UserDetail: Codable {
    let login : String
    let name : String?
    let bio : String?
    let followers : Int
    let following : Int
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case login
        case name
        case bio
        case followers
        case following
        case avatarURL = "avatar_url"
    }
}
