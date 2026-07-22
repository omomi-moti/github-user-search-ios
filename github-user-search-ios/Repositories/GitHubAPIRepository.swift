import Foundation

struct GitHubAPIRepository: GitHubRepository {

    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    func searchUsers(keyword: String) async throws -> [SearchUser] {
        let url = Endpoint.searchUsers(keyword: keyword).url
        let data = try await client.fetchData(url)
        let response: SearchUsersResponse = try client.decode(data)
        return response.items
    }
    
    func fetchUserDetail(username: String) async throws -> UserDetail {
        let url = Endpoint.userDetail(username: username).url
        let data = try await client.fetchData(url)
        return try client.decode(data)
    }
    
    func fetchUserRepositories(username: String,page : Int) async throws -> [Repo] {
        let url = Endpoint.repos(username: username,page : page).url
        let data = try await client.fetchData(url)
        return try client.decode(data)
    }
}
