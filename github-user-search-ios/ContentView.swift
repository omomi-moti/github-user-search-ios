//
//  ContentView.swift
//  github-user-search-ios
//
//  Created by 鈴木聖也 on 2026/07/08.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("検索", systemImage: "magnifyingglass")
                }

            NavigationStack {
                FavoriteListView()
            }
            .tabItem {
                Label("お気に入り", systemImage: "star")
            }
        }
    }
}

#Preview {
    ContentView()
}
