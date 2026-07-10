import Foundation
import SwiftData

@Model
class FFavoriteUse{
    var username : String
    var avatarURL: String
    var name : String?
    var savedAt: Date
    
    init(username: String, avatarURL: String, name: String?, savedAt: Date = .now) {
        self.username = username
        self.avatarURL = avatarURL
        self.name = name
        self.savedAt = savedAt
    }
}
