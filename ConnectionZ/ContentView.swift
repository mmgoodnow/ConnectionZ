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

extension Array where Element: Game {
  subscript(id: Int) -> Game? {
    first { $0.id == id }
  }
}

struct ContentView: View {
  let backgroundImporter: BackgroundImporter
  
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.modelContext) private var modelContext
  @SceneStorage("ContentView.selectedId") private var selectedId: Int?
  
  @Query(sort: \Game.id) private var persistedGames: [Game]
  
  init(backgroundImporter: BackgroundImporter) {
    self.backgroundImporter = backgroundImporter
  }
  
  private func onAppear() {
    if selectedId == nil {
      if let todaysGame = game(for: Date()) {
        selectedId = selectedId ?? todaysGame.id
      }
    }
    Task { [backgroundImporter] in
      await backgroundImporter.synchronizeWithServer()
      if selectedId == nil {
        if let todaysGame = game(for: Date()) {
          selectedId = selectedId ?? todaysGame.id
        }
      }
    }
  }
  
  private func game(for date: Date) -> Game? {
    return self.persistedGames.first { $0.id == Game.id(for: date)}
  }
  
  var body: some View {
    NavigationSplitView {
      if persistedGames.isEmpty {
        ProgressView().navigationTitle("ConnectionZ")
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
      if let id = selectedId {
        GameView(game: persistedGames[id])
          .navigationTitle(persistedGames[id].name)
          .frame(minWidth: 300, maxWidth: 1000, minHeight: 400, maxHeight: 1000)
          .aspectRatio(3/4, contentMode: .fit)
      } else {
        ProgressView {
          Text("Loading games from NYT servers")
        }
      }
    }
    .onAppear(perform: onAppear)
    .background(colorScheme == .dark ? Color.background : Color.white)
  }
}


