import Foundation

enum Endpoint{
    case searchUsers(keyword : String)//userの情報を取得するためのエンドポイント
    case userDetail(username : String)//userの詳細情報を取得するためのエンドポイント
    case repos(username : String , page : Int = 1)//ユーザーのリポジトリを取得するためのエンドポイント
    case favorites//お気に入り一覧を取得するためのエンドポイント（ローカルサーバー）

    func url(on server: APIServer) -> URL? { //接続先を受け取ってURLを組み立てる
        var components = URLComponents()
        components.scheme = server.scheme
        components.host = server.host
        components.port = server.port

        switch self{
        case .searchUsers(let keyword):
            components.path = "/search/users"
            components.queryItems = [URLQueryItem(name: "q",value : keyword)]

        case .userDetail(let username):
            components.path = "/users/\(username)"

        case .repos(let userName , let page):
            components.path = "/users/\(userName)/repos"
            components.queryItems = [
                    URLQueryItem(name: "page",value : "\(page)"),
                    URLQueryItem(name: "per_page",value : "30")
            ]

        case .favorites:
            components.path = "/favorites"
        }
        return components.url
    }
}
