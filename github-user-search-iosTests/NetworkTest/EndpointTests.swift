import Foundation
import Testing
@testable import github_user_search_ios

struct EndpointTests {
    @Test("検索APIのURLが正しく組み立てられる")
    func searchUsersURLIsCorrect(){
        let url = Endpoint.searchUsers(keyword : "swift").url(on: .github)
        #expect(url?.absoluteString == "https://api.github.com/search/users?q=swift")
    }
    @Test("ユーザー詳細APIのURLが正しく組み立てられる")
    func userURLIsCorrect(){
        let url = Endpoint.userDetail(username: "swift").url(on: .github)
        #expect(url?.absoluteString == "https://api.github.com/users/swift")
    }
    @Test("リポジトリ一覧のURLを正しく組み立てられる")
    func reposURLISCorrect(){
        let url = Endpoint.repos(username: "swift", page: 1).url(on: .github)
        #expect(url?.absoluteString == "https://api.github.com/users/swift/repos?page=1&per_page=30")
    }
    @Test("ローカルサーバーのお気に入り一覧のURLが正しく組み立てられる")
    func favoritesURLIsCorrect(){
        let url = Endpoint.favorites.url(on: .local)
        #expect(url?.absoluteString == "http://localhost:8080/favorites")
    }
    @Test("ローカルサーバーのお気に入り1件のURLが正しく組み立てられる")
    func favoriteURLIsCorrect(){
        let url = Endpoint.favorite(username: "swift").url(on: .local)
        #expect(url?.absoluteString == "http://localhost:8080/favorites/swift")
    }
}
