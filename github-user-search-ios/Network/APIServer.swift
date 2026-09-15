import Foundation

struct APIServer {
    let scheme: String
    let host: String
    let port: Int?

    static let github = APIServer(scheme: "https", host: "api.github.com", port: nil)
    static let local = APIServer(scheme: "http", host: "localhost", port: 8080)
}
