import Foundation
@testable import github_user_search_ios

//受け取ったリクエストを記録するURLSession(POSTのメソッドやボディが送られているかを確かめるため)
final class RecordingURLSession: URLSessionProtocol {
    let statusCode: Int
    let data: Data
    private(set) var lastRequest: URLRequest?

    init(statusCode: Int, data: Data) {
        self.statusCode = statusCode
        self.data = data
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}
