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
  @Environment(\.modelContext) private var modelContext
  @State var updater: Bool = false
  @Query(sort: \Game.id) private var persistedGames: [Game]
  
  private func game(for date: Date) -> Game? {
    return self.persistedGames.first { $0.id == Game.id(for: date)}
  }
  
  private func downloadSelectedGame() async {
    if let id = selectedId {
      if persistedGames.by(id: id) == nil  {
        print("Fetching puzzle \(id)")
        let response = await ConnectionsApi.fetchBy(id: id)
        if let gameData = response {
          print("Inserting puzzle \(id)")
          modelContext.insert(Game(from: gameData))
          try! modelContext.save()
        }
      }
    }
  }
  
  
  var body: some View {
    let _ = print("rendering nav, games are \(persistedGames.map(\.id))")
    NavigationSplitView {
      List(selection: $selectedId) {
        Section(header: Text("Current")) {
          NavigationLink("Today's Game", value: Game.id(for: Date()))
          NavigationLink("Yesterday's Game", value: Game.id(for: Date().add(days: -1)))
        }
        GameGroupingView(sectionName: "In Progress", ids: persistedGames.filter(\.isInProgress).map(\.id))
        GameGroupingView(sectionName: "Completed", ids: persistedGames.filter(\.isComplete).map(\.id))
        GameGroupingView(
          sectionName: "Archive",
          ids: Array(1...Game.id(for: Date())).reversed(),
          startCollapsed: true
        )
      }.navigationTitle("ConnectionZ")
    } detail: {
      let _ = print("selectedId \(String(describing: selectedId))")
      if let game = persistedGames.by(id: selectedId) {
        GameView(game: game)
          .navigationTitle(game.name)
#if os(iOS)
          .navigationBarTitleDisplayMode(.inline)
#endif
      } else {
        Text("Select a game")
      }
    }.onChange(of: selectedId, initial: true) {
      Task {
        await downloadSelectedGame()
      }
    }
  }
}

