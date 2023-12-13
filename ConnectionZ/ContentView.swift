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
  
  func by(date dateMaybe: String?) -> Game? {
    guard let date = dateMaybe else {
      return nil
    }
    return first { $0.date == date }
  }
}

struct ContentView: View {
  @Environment(\.colorScheme) private var colorScheme
  @SceneStorage("ContentView.selectedDate") private var selectedDate: String?
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Game.date) private var persistedGames: [Game]
  
  private func downloadSelectedGame() async {
    if let date = selectedDate {
      if persistedGames.by(date: date) == nil  {
        print("Fetching puzzle \(date)")
        let response = await ConnectionsApi.fetchBy(date: date)
        if let gameData = response {
          print("Inserting puzzle \(gameData.id) - \(date)")
          modelContext.insert(Game(from: gameData, on: date))
          try? modelContext.save()
        }
      }
    }
  }
  
  
  var body: some View {
    let _ = print("rendering nav, games are \(persistedGames.map(\.id))")
    NavigationSplitView {
      List(selection: $selectedDate) {
        Section(header: Text("Current")) {
          NavigationLink("Today's Game", value: Date().iso8601())
          NavigationLink("Yesterday's Game", value: Date().add(days: -1).iso8601())
        }
        GameGroupingView(sectionName: "In Progress", dates: persistedGames.filter(\.isInProgress).map(\.date))
        GameGroupingView(sectionName: "Completed", dates: persistedGames.filter(\.isComplete).map(\.date))
        GameGroupingView(
          sectionName: "Archive",
          dates: Array(DateSequence(startDate: Date().snapToDay())).map { $0.iso8601() },
          startCollapsed: true
        )
      }.navigationTitle("ConnectionZ")
    } detail: {
      if let game = persistedGames.by(date: selectedDate) {
        GameView(game: game)
          .navigationTitle(game.name)
#if os(iOS)
          .navigationBarTitleDisplayMode(.inline)
#endif
      } else {
        Text("Select a game")
      }
    }.onChange(of: selectedDate, initial: true) {
      Task {
        await downloadSelectedGame()
      }
    }
  }
}

