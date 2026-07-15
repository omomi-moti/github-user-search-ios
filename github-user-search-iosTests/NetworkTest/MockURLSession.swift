import Foundation
@testable import github_user_search_ios

struct MockURLSession: URLSessionProtocol {
    let statusCode: Int
    let data: Data

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}
