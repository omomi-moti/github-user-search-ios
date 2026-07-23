import Foundation

protocol GitHubRepository {
    func searchUsers(keyword: String) async throws -> [SearchUser] 
    func fetchUserDetail(username: String) async throws -> UserDetail
    func fetchUserRepositories(username: String , page : Int) async throws -> [Repo]
}
