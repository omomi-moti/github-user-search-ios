import Foundation

struct APIClient {
    private let session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func fetchData(_ url : URL?, method : String = "GET", body : Data? = nil) async throws -> Data{ //methodとbodyは省略するとGETになる
        guard  let url  else{
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url : url)
        request.httpMethod = method
        request.httpBody = body
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") //送るボディがJSONであることを伝える
        }
        
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept") //JSON形式で、GitHub APIバージョンに準拠したレスポンスを要求する
        request.setValue("github-user-search-ios", forHTTPHeaderField: "User-Agent") //リクエスト先を提示
        
        let (data,response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else{
            throw NetworkError.unknown(statusCode: nil)
        }
        switch httpResponse.statusCode{
        case 200...299:
            return data
            
        case 403,429:
            throw NetworkError.rateLimited
        case 400:
            throw NetworkError.badRequest
        case 422:
            throw NetworkError.validationError
        case 404:
            throw NetworkError.notFound
        case 409:
            throw NetworkError.conflict
        case 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default :
            throw NetworkError.unknown(statusCode: httpResponse.statusCode)
        }
    }
    func decode<T: Decodable> (_ data : Data) throws -> T { //Decodeに準拠したもののみ通す関数(エンドポイントを使い回すため)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 //サーバーのsavedAt("2026-09-13T10:00:00Z")をDateで受け取るため
        do{
            return try decoder.decode(T.self, from: data)
        }
        
        catch{
            throw NetworkError.decodingError
        }
        
    }
}

