import Foundation

enum ViewState<T>{
    case idle //まだ何もしてない状態
    case loading //ロード中の状態
    case loaded(T) //データが手元にある状態
    case error(String) //通信が失敗した状態
}

extension ViewState: Equatable where T: Equatable {}
