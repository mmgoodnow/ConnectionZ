//
//  ContentView.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/9/23.
//

import SwiftUI
import SwiftData
import SwiftSoup

extension Array where Element: Game {
  func by(id idMaybe: Int?) -> Game? {
    guard let id = idMaybe else {
      return nil
    }
    return first { $0.id == id }
  }
}

struct ContentView: View {
  @Environment(\.colorScheme) private var colorScheme
  @SceneStorage("ContentView.selectedId") private var selectedId: Int?
  
  @Query(sort: \Game.id) private var persistedGames: [Game]
  
  private func game(for date: Date) -> Game? {
    return self.persistedGames.first { $0.id == Game.id(for: date)}
  }
  
  
  var body: some View {
    NavigationSplitView {
      if persistedGames.isEmpty {
        ProgressView {
          Text("Loading games")
        }.navigationTitle("ConnectionZ")
      } else {
        List(selection: $selectedId) {
          Section(header: Text("Current")) {
            NavigationLink("Today's Game", value: game(for: Date())?.id ?? 0)
            NavigationLink("Yesterday's Game", value: game(for: Date().add(days: -1))?.id ?? 0)
          }
          GameGroupingView(sectionName: "In Progress", games: persistedGames.filter(\.isInProgress))
          GameGroupingView(sectionName: "Completed", games: persistedGames.filter(\.isComplete))
          GameGroupingView(
            sectionName: "Archive",
            games: persistedGames.filter(\.isPublished).reversed(),
            startCollapsed: true
          )
        }.navigationTitle("ConnectionZ")
      }
    } detail: {
      if let game = persistedGames.by(id: selectedId) {
        GameView(game: game)
          .navigationTitle(game.name)
#if os(iOS)
          .navigationBarTitleDisplayMode(.inline)
#endif
      } else {
        Text("Select a game")
      }
    }
    .background(colorScheme == .dark ? Color.background : Color.white)
  }
}

