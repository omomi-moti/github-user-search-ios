import Foundation

enum NetworkError : Error{
    case invalidURL
    case rateLimitted
    case decodingError
    case unknown
}
