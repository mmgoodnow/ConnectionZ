//
//  DraggableConnectionsApp.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/9/23.
//

import SwiftUI
import SwiftData

private func createModelContainer() -> ModelContainer {
  let schema = Schema([Game.self])
  let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
  
  do {
    return try ModelContainer(for: schema, configurations: [modelConfiguration])
  } catch {
    fatalError("Could not create ModelContainer: \(error)")
  }
}

@main
struct ConnectionZApp: App {
  let sharedModelContainer: ModelContainer
  
  init() {
    self.sharedModelContainer = createModelContainer()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedModelContainer)
  }
}
