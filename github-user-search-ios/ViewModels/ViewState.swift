import Foundation

enum ViewState<T>{
    case idle //まだ何もしてない状態
    case loading //ロード中の除隊
    case loaded(T) //データが手元にある状態
    case error(String) //通信が失敗した状態
}
