import Foundation

struct SearchHistoryStore{
    private let key = "searchHistory"
    private let limit: Int = 20
    private let userDefaults: UserDefaults
    
    init(userDefaults : UserDefaults = .standard){
        self.userDefaults = userDefaults
    }
    
    func load() ->[String]{
        guard let data = userDefaults.data(forKey : key),
              let history = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return history
    }
    
    func add(_ keyword : String){
        var history = load()
        history.removeAll{ existingKeyword in
            return existingKeyword == keyword
        }
        history.insert(keyword, at: 0)
        
        if history.count > limit{
            history = Array(history.prefix(limit))
        }
        save(history)
    }
    
    func remove(_ keyword : String){
        var history = load()
        history.removeAll { existingKeyword in
            return existingKeyword == keyword
        }
        save(history)
    }
    
    func clear(){
        userDefaults.removeObject(forKey: key)
    }
    
    private func save(_ history: [String]) {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: key)
        }
    }
}
