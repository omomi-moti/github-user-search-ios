//
//  github_user_search_iosApp.swift
//  github-user-search-ios
//
//  Created by 鈴木聖也 on 2026/07/08.
//

import SwiftUI
import SwiftData
@main
struct github_user_search_iosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: FavoriteUser.self)
    }
}
