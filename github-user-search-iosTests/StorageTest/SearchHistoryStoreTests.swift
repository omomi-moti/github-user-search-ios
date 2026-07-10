import Testing
import Foundation
@testable import github_user_search_ios

struct SearchHistoryStoreTests {
    //テスト用のローカルデータベースの初期化
    private func makeStore() -> SearchHistoryStore {
        let suiteName = "test_\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        return SearchHistoryStore(userDefaults: userDefaults)
    }
    @Test("履歴がない状態では、空配列が返る")
    func loadReturnsEmptyWhenNoHistory() throws {
        let store = makeStore()
        #expect(store.load().isEmpty)
    }
    @Test("追加した履歴が先頭に追加される")
    func addInsertsAtFront(){
        let store = makeStore()
        store.add("swift")
        store.add("kotlin")
        
        let history = store.load()
        #expect(history.count == 2)
        #expect(history == ["kotlin","swift"])
    }
    @Test("同じキーワードを追加しても重複せず先頭に移動する")
    func addMovesExistingKeywordToFront(){
        let store = makeStore()
        store.add("swift")
        store.add("kotlin")
        store.add("swift")
        
        let history = store.load()
        #expect(history.count == 2)
        #expect(history == ["swift","kotlin"])
    }
    
    @Test("上限件数を超えると古いものが間引かれる")
    func addRemovesOldestWhenOverLimit(){
        let store = makeStore()
        for i in 1...21{
            store.add("keyword-\(i)")
        }
        let history = store.load()
        #expect(history.count == 20)
        #expect(history.first == "keyword-21")
        #expect(!history.contains("keyword-1"))
    }
    @Test("特定のキーワードを削除することができる")
    func removeDeletesSpecificKeyword(){
        let store = makeStore()
        store.add("swift")
        store.add("kotlin")
        store.remove("swift")
        
        let history = store.load()
        #expect(history == ["kotlin"])
    }
    
    @Test("clearで全履歴が削除される")
    func clearClearsHistory(){
        let store = makeStore()
        store.add("swift")
        store.add("kotolin")
        store.clear()
        
        #expect(store.load().isEmpty)
    }
}
