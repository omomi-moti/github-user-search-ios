import Foundation

struct MockGitHubRepository : GitHubRepository{
    var shouldFail = false
    var errorToThrow: NetworkError = .rateLimited

    func searchUsers(keyword: String) async throws -> [SearchUser] {
        if shouldFail {
            throw errorToThrow
        }
        return [
            SearchUser(id: 1, login: "swift", avatarURL: "https://example.com/octocat.png")
        ]
    }

    func fetchUserDetail(username: String) async throws -> UserDetail {
        if shouldFail {
            throw errorToThrow
        }
        return UserDetail(
            login: "swift",
            name: "The swift",
            bio: nil,
            followers: 100,
            following: 9,
            avatarURL: "https://example.com/octocat.png"
        )
    }

    func fetchUserRepositories(username: String, page: Int) async throws -> [Repo] {
        if shouldFail {
            throw errorToThrow
        }
        return [
            Repo(id: 1, name: "Hello-World", description: nil, language: "Swift", stargazersCount: 80, htmlURL: "https://github.com/octocat/Hello-World")
        ]
    }
}
