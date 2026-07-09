import Foundation
import Testing
@testable import github_user_search_ios

struct APIClientTests {
    let client = APIClient()
    
    @Test("API通信でユーザーの情報を取得できるか")
    func fetchRealSearchUsers() async throws{
        let url = Endpoint.searchUsers(keyword: "swift").url
        let data = try await client.fetchData(url)
        let response: SearchUsersResponse = try client.decode(data)
        #expect(!response.items.isEmpty)
        
        let logins = response.items.map{ item in
            return item.login
        }
        #expect(logins.contains("swift"))
    }
    @Test("API通信でユーザーの詳細情報を取得できる")
    func fetchDetailUser() async throws{
        let url = Endpoint.userDetail(username: "swiftlang").url
        let data = try await client.fetchData(url)
        let detail : UserDetail = try client.decode(data)
        
        #expect(detail.login == "swiftlang")
        #expect(detail.avatarURL.isEmpty == false)
    }
    @Test("API通信でユーザーのリポジトリ情報を取得できる")
    func fetchDetailUserRepos() async throws{
        let url = Endpoint.repos(username: "swiftlang").url
        let data = try await client.fetchData(url)
        let repos : [Repo] = try client.decode(data)
        
        #expect(!repos.isEmpty)
        
        let repoNames = repos.map { repo in
            return repo.name
        }
        #expect(repoNames.contains("swift"))
    }
}
