//
//  ContentView.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/9/23.
//

import SwiftUI
import SwiftData
import SwiftSoup

public extension Color {
#if os(macOS)
  static let background = Color(NSColor.windowBackgroundColor)
  static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
  static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
#else
  static let background = Color(UIColor.systemBackground)
  static let secondaryBackground = Color(UIColor.secondarySystemBackground)
  static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
#endif
}

struct ContentView: View {
  let backgroundImporter: BackgroundImporter
  
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.modelContext) private var modelContext
  @State private var selection: Game? = nil
  
  @Query(sort: \Game.id) private var persistedGames: [Game]
  
  init(backgroundImporter: BackgroundImporter) {
    self.backgroundImporter = backgroundImporter
  }
  
  private func loadItems() {
    Task { [backgroundImporter] in
      await backgroundImporter.synchronizeWithServer()
    }
  }
  
  private func game(for date: Date) -> Game {
    return self.persistedGames.first { $0.id == Game.id(for: date)}!
  }
  
  var inProgressGames: [Game] {
    return persistedGames.filter(\.isInProgress)
  }
  
  var body: some View {
    NavigationSplitView {
      if persistedGames.isEmpty {
        ProgressView().navigationTitle("ConnectionZ")
      } else {
        List(selection: $selection) {
          Section(header: Text("Current")) {
            NavigationLink("Today's Game", value: game(for: Date()))
            NavigationLink("Yesterday's Game", value: game(for: Date().add(days: -1)))
          }
          if (!inProgressGames.isEmpty) {
            Section(header: Text("In Progress")) {
              ForEach(inProgressGames) { game in
                NavigationLink(game.name, value: game)
              }
            }
          }
          Section(header: Text("Archive")) {
            ForEach(persistedGames) { game in
              NavigationLink(game.name, value: game)
            }
          }
        }.navigationTitle("ConnectionZ")
      }
    } detail: {
      if let game = selection {
        GameView(game: game)
          .navigationTitle(game.name)
          .frame(minWidth: 300, maxWidth: 1000, minHeight: 400, maxHeight: 1000)
          .aspectRatio(3/4, contentMode: .fit)
      } else {
        ProgressView {
          Text("Loading games from NYT servers")
        }
      }
    }
    .onAppear(perform: loadItems)
    .background(colorScheme == .dark ? Color.background : Color.white)
  }
}


