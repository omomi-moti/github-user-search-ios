import Testing
import Foundation
import SwiftData
@testable import github_user_search_ios

@MainActor
struct FavoriteViewModelTests {
    
    private func makeViewModel() throws -> (FavoriteViewModel, ModelContext)  {
        let config = ModelConfiguration(isStoredInMemoryOnly: true) //メモリ上だけに一時的にDBを作る設定をする
        let container = try ModelContainer(for: FavoriteUser.self, configurations: config)//FavoriteUserを保存できる仮データベースを作成(メモリ上)
        let context = ModelContext(container)//実際にデータを読み書きするための窓口を作成
        let viewModel = FavoriteViewModel(modelContext: context) // 窓口(context)を渡して、テストしたい本体であるFavoriteViewModel
        return (viewModel, context)
    }
    
    @Test("お気に入りに追加すると、一覧に反映される")
    func addFavorite() async throws {
        let (viewModel, context) = try makeViewModel()
        viewModel.add(username: "swift", avatarURL: "https://swift.com/a.png", name: "The Swift")
        
        let descriptor = FetchDescriptor<FavoriteUser>()
        let results = try context.fetch(descriptor)
        
        #expect(results.count == 1)
        #expect(results.first?.username == "swift")
    }
    
    @Test("お気に入りを削除すると、一覧から消える")
    func removeFavorite() async throws {
        let (viewModel, context) = try makeViewModel()
        viewModel.add(username: "swift", avatarURL: "https://swift.com/a.png", name: "The Swift")
        
        let descriptor = FetchDescriptor<FavoriteUser>()
        var results = try context.fetch(descriptor)
        
        guard let favorite = results.first else {
            Issue.record("追加したお気に入りが見つからない")
            return
        }
        
        viewModel.remove(favorite)
        results = try context.fetch(descriptor)
        #expect(results.isEmpty)
    }
    
    @Test("isFavoriteが登録状態を正しく判定する")
    func isFavoriteReturnsCorrectResult() throws {
        let (viewModel, context) = try makeViewModel()
        viewModel.add(username: "swift", avatarURL: "https://swift.com/a.png", name: "The Swift")
        
        let descriptor = FetchDescriptor<FavoriteUser>()
        let favorites = try context.fetch(descriptor)
        
        #expect(viewModel.isFavorite(username: "swift", favorites: favorites) == true)
        #expect(viewModel.isFavorite(username: "octocat", favorites: favorites) == false)
    }
    
    @Test("toggleで未登録なら追加、登録済みなら削除される")
    func toggleAddsAndRemoves() throws {
        let (viewModel, context) = try makeViewModel()
        let descriptor = FetchDescriptor<FavoriteUser>()
        
        var favorites = try context.fetch(descriptor)
        
        viewModel.toggle(username: "swift", avatarURL: "https://swift.com/a.png", name: "The Swift", favorites: favorites)
        
        favorites = try context.fetch(descriptor)
        #expect(favorites.count == 1)
        
        viewModel.toggle(username: "swift", avatarURL: "https://swift.com/a.png", name: "The Swift", favorites: favorites)
        favorites = try context.fetch(descriptor)
        #expect(favorites.isEmpty)
    }
}
