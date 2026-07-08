import Foundation

struct SearchUsersResponse : Codable{
    let totalCount : Int
    let items : [SearchUser]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}
