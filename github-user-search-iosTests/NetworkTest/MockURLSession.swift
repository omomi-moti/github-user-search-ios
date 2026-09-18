import Foundation
@testable import github_user_search_ios

struct MockURLSession: URLSessionProtocol {
    let statusCode: Int
    let data: Data
    var error: Error? = nil //指定すると、レスポンスの代わりにこのエラーを投げる

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error {
            throw error
        }
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}
