import Foundation

enum NetworkError : Error, Equatable {
    case invalidURL // URLの組み立てに失敗した場合
    case rateLimited// 403（上限超過）/ 429（二次制限）：レート制限
    case validationError // 422：検索クエリなどのバリデーションエラー
    case notFound // 404：指定したユーザーが存在しない
    case serverError(statusCode: Int)// 5xx：GitHub側のサーバーエラー
    case decodingError// 2xxだがJSONのデコードに失敗した場合
    case unknown(statusCode: Int?)// 上記以外の想定外のステータスコード
}

extension NetworkError{
    var userMessage : String {
        switch self{
            case .invalidURL:
                return "URLが不正です"
            case .rateLimited:
                return "アクセス制限中です、しばらく待ってからお試しください"
            case .validationError:
                return "検索キーワードが正しくありません"
            case .notFound:
                return "ユーザーが見つかりませんでした"
            case .serverError:
                return "サーバーエラーが発生しました。時間をおいて再度お試しください"
            case .decodingError:
                return "データの読み込みに失敗しました"
            case .unknown:
                return "予期せぬエラーが発生しました"
            
        }
    }
}
