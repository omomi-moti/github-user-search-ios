import Foundation

enum Endpoint{
    case searchUsers(keyword : String)//userの情報を取得するためのエンドポイント
    case userDetail(username : String)//userの詳細情報を取得するためのエンドポイント
    case repos(username : String)//ユーザーのリポジトリを取得するためのエンドポイント
    
    var url : URL?{
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        
        switch self{
        case .searchUsers(let keyward):
            components.path = "/search/users"
            components.queryItems = [URLQueryItem(name: "q",value : keyward)]
        
        case .userDetail(let username):
            components.path = "/users/\(username)"
        
        case .repos(let userName):
            components.path = "/users/\(userName)/repos"
        }
        return components.url
    }
    
    
}
