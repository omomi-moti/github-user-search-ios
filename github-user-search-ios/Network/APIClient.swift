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
        
        if let httpResponse = response as?  HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode){
            
            if httpResponse.statusCode == 403 || httpResponse.statusCode == 422 {
                
                throw NetworkError.rateLimitted
            }
            
            throw NetworkError.unknown
            
        }
        return data
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

