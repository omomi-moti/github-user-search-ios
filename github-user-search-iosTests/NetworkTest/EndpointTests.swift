import Foundation
import Testing
@testable import github_user_search_ios

struct EndpointTests {
    @Test("検索APIのURLが正しく組み立てられる")
    func searchUsersURLIsCorrect(){
        let url = Endpoint.searchUsers(keyword : "swift").url
        #expect(url?.absoluteString == "https://api.github.com/search/users?q=swift")
    }
    @Test("ユーザー詳細APIのURLが正しく組み立てられる")
    func userURLIsCorrect(){
        let url = Endpoint.userDetail(username: "swift").url
        #expect(url?.absoluteString == "https://api.github.com/users/swift")
    }
    @Test("リポジトリ一覧のURLを正しく組み立てられる")
    func reposURLISCorrect(){
        let url = Endpoint.repos(username: "swift").url
        #expect(url?.absoluteString == "https://api.github.com/users/swift/repos")
    }
}
