//
//  ContentView.swift
//  AI Tauihi App
//
//  Created by Jayden Rosanowski on 16/07/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeViewAlt()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            GamesView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Games")
                }
            TeamsView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Teams")
                }
            StandingsView()
                .tabItem {
                    Image(systemName: "list.number")
                    Text("Standings")
                }
            MoreView()
                .tabItem {
                    Image(systemName: "ellipsis.circle")
                    Text("More")
                }
        }
        .accentColor(Color.tauihiRed)
    }
}

#Preview {
    ContentView()
}
