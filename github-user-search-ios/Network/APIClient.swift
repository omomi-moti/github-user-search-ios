import Foundation

struct APIClient {
    
    func fetchData(_ url : URL?) async throws -> Data{
        guard  let url  else{
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url : url)
        
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept") //JSON形式で、GitHub APIバージョンに準拠したレスポンスを要求する
        request.setValue("github-user-search-ios", forHTTPHeaderField: "User-Agent") //リクエスト先を提示
        
        let (data,response) = try await URLSession.shared.data(for :request)
        
        guard let httpResponse = response as? HTTPURLResponse else{
            throw NetworkError.unknown(statusCode: nil)
        }
        switch httpResponse.statusCode{
        case 200...299:
            return data
            
        case 403,429:
            throw NetworkError.rateLimitted
        case 422:
            throw NetworkError.validationError
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default :
            throw NetworkError.unknown(statusCode: httpResponse.statusCode)
        }
    }
    func decode<T: Decodable> (_ data : Data) throws -> T { //Decodeに準拠したもののみ通す関数(エンドポイントを使い回すため)
        
        do{
            return try JSONDecoder().decode(T.self, from: data)
        }
        
        catch{
            throw NetworkError.decodingError
        }
        
    }
}

