import Foundation

struct Repo : Codable , Identifiable {
    let id : Int
    let name : String
    let description: String?
    let language : String?
    let stargazersCount: Int
    let htmlURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case language
        case stargazersCount = "stargazers_count"
        case htmlURL = "html_url"
    }
}
