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
  @State var isFetching = false
  @State var allGames = [GameData]()
  @State private var selection: GameData? = nil
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    NavigationSplitView {
      if isFetching {
        ProgressView()
      } else {
        List(allGames, id: \.self, selection: $selection) { gameData in
          NavigationLink(gameData.name, value: gameData)
        }
      }
    } detail: {
      if let gameData = selection {
        GameView(game: Game.from(gameData: gameData)).navigationTitle(gameData.name)
      } else {
        ProgressView {
          Text("Loading games from NYT servers")
        }
      }
    }
    .onAppear(perform: loadItems)
    .background(colorScheme == .dark ? Color.background : Color.white)
  }
  
  private func loadItems() {
    self.isFetching = true;
    Task {
      self.allGames = await ConnectionsApi.fetchAllConnectionsGames()
      self.isFetching = false;
      self.selection = allGames.first(where: { $0.id == gameIdFor(date: Date())})
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      allGames.remove(atOffsets: offsets)
    }
  }
}


