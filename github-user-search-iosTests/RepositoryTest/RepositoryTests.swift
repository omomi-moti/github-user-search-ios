import Testing
import Foundation
@testable import github_user_search_ios

struct RepositoryTests {
    
    @Test("検索が成功した場合、SearchUserの配列が返る")
    func searchUsersSucceeds() async throws {
        let repository = MockGitHubRepository(shouldFail: false)
        let users = try await repository.searchUsers(keyword: "swift")
        
        #expect(!users.isEmpty)
        #expect(users.first?.login == "swift")
    }
    
    @Test("ユーザーの詳細情報が取得できた場合、UserDetail型が返ってくる")
    func getUserDetailSucceeds() async throws {
        let repository = MockGitHubRepository(shouldFail: false)
        let detail = try await repository.fetchUserDetail(username: "swift")
        
        #expect(detail.login == "swift")
        #expect(detail.bio == nil)
    }
    @Test("ユーザーのリポジトリ情報が取得できた場合,Repoが返る")
    func getUserReposSucceeds() async throws {
        let repository = MockGitHubRepository(shouldFail: false)
        let repos = try await repository.fetchUserRepositories(username: "swift")
        
        #expect(!repos.isEmpty)
        #expect(repos.first?.name == "Hello-World")
        #expect(repos.first?.language == "Swift")
    }
}
