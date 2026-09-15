import Foundation

struct GitHubAPIRepository: GitHubRepository {

    private let client: APIClient
    private let server: APIServer

    init(client: APIClient = APIClient(), server: APIServer = .github) {
        self.client = client
        self.server = server
    }
    func searchUsers(keyword: String) async throws -> [SearchUser] {
        let url = Endpoint.searchUsers(keyword: keyword).url(on: server)
        let data = try await client.fetchData(url)
        let response: SearchUsersResponse = try client.decode(data)
        return response.items
    }
    
    func fetchUserDetail(username: String) async throws -> UserDetail {
        let url = Endpoint.userDetail(username: username).url(on: server)
        let data = try await client.fetchData(url)
        return try client.decode(data)
    }
    
    func fetchUserRepositories(username: String,page : Int) async throws -> [Repo] {
        let url = Endpoint.repos(username: username,page : page).url(on: server)
        let data = try await client.fetchData(url)
        return try client.decode(data)
    }
}
