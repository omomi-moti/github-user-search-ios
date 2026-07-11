import Foundation
import Observation
import SwiftData

@Observable
@MainActor
class FavoriteViewModel{
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext){
        self.modelContext = modelContext
    }
    
    func add(username: String, avatarURL: String, name: String?) {
        let favorite = FavoriteUser(username: username, avatarURL: avatarURL, name: name)
        modelContext.insert(favorite)
    }
    func remove(_ favorite: FavoriteUser) {
        modelContext.delete(favorite)
    }
    
    func isFavorite(username: String,favorites : [FavoriteUser]) -> Bool {
        return favorites.contains { favorite in
            return favorite.username == username
        }
    }
    
    func toggle(username: String, avatarURL: String, name: String?, favorites: [FavoriteUser]) {
        let existing = favorites.first { favorite in
            return favorite.username == username
        }
        
        if let existing = existing {
            remove(existing)
        } else {
            add(username: username, avatarURL: avatarURL, name: name)
        }
    }
}
