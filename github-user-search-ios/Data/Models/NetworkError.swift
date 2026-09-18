import Foundation

enum NetworkError : Error, Equatable {
    case invalidURL // URLの組み立てに失敗した場合
    case rateLimited// 403（上限超過）/ 429（二次制限）：レート制限
    case badRequest // 400：リクエストの形式や必須項目が不正
    case validationError // 422：検索クエリなどのバリデーションエラー
    case notFound // 404：指定したユーザーが存在しない
    case conflict // 409：すでに登録されている
    case serverError(statusCode: Int)// 5xx：GitHub側のサーバーエラー
    case connectionFailed // 通信できなかった場合（オフライン・サーバーに届かない・時間切れ）
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
            case .badRequest:
                return "リクエストの内容が正しくありません"
            case .validationError:
                return "検索キーワードが正しくありません"
            case .notFound:
                return "ユーザーが見つかりませんでした"
            case .conflict:
                return "すでに登録されています"
            case .serverError:
                return "サーバーエラーが発生しました。時間をおいて再度お試しください"
            case .connectionFailed:
                return "通信できませんでした。通信環境を確認してください"
            case .decodingError:
                return "データの読み込みに失敗しました"
            case .unknown:
                return "予期せぬエラーが発生しました"
            
        }
    }
}
