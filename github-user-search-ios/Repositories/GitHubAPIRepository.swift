import Foundation

struct GitHubAPIRepository: GitHubRepository {
    let clinet = APIClient()

    func searchUsers(keyword: String) async throws -> [SearchUser] {
        let url = Endpoint.searchUsers(keyword: keyword).url
        let data = try await clinet.fetchData(url)
        let response: SearchUsersResponse = try clinet.decode(data)
        return response.items
    }

    func fetchUserDetail(username: String) async throws -> UserDetail {
        let url = Endpoint.userDetail(username: username).url
        let data = try await clinet.fetchData(url)
        return try clinet.decode(data)
    }

    func fetchUserRepositories(username: String) async throws -> [Repo] {
        let url = Endpoint.repos(username: username).url
        let data = try await clinet.fetchData(url)
        return try clinet.decode(data)
    }
}
