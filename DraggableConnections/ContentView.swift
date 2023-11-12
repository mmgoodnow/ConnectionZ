//
//  ContentView.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/9/23.
//

import SwiftUI
import SwiftData
import SwiftSoup

struct ContentView: View {
  @State var isFetching = false
  @State var allGames = [GameData]()
  
  var body: some View {
    NavigationSplitView {
      if isFetching {
        Text("isFetching")
      } else {
        List {
          ForEach(allGames) { gameData in
            NavigationLink {
              GameView(gameData: gameData)
            } label: {
              Text("Game \(gameData.id)")
            }
          }
          .onDelete(perform: deleteItems)
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        .toolbar {
#if os(iOS)
          ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
          }
#endif
          ToolbarItem {
            Button(action: loadItems) {
              Label("Add Item", systemImage: "plus")
              
            }
          }
        }}
    } detail: {
      Text("Select an item")
    }
  }
  
  private func loadItems() {
    self.isFetching = true;
    Task {
      self.allGames = await ConnectionsApi.fetchAllConnectionsGames()
      self.isFetching = false;
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
        allGames.remove(atOffsets: offsets)
    }
  }
}


