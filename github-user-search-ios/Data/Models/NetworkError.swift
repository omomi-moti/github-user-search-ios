import Foundation

enum NetworkError : Error{
    case invalidURL // URLの組み立てに失敗した場合
    case rateLimited// 403（上限超過）/ 429（二次制限）：レート制限
    case validationError // 422：検索クエリなどのバリデーションエラー
    case notFound // 404：指定したユーザーが存在しない
    case serverError(statusCode: Int)// 5xx：GitHub側のサーバーエラー
    case decodingError// 2xxだがJSONのデコードに失敗した場合
    case unknown(statusCode: Int?)// 上記以外の想定外のステータスコード
}
