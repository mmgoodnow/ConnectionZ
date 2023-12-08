//
//  BackgroundImportenr.swift
//  ConnectionZ
//
//  Created by Michael Goodnow on 11/22/23.
//

import Foundation
import SwiftData

actor BackgroundImporter {
  let modelContainer: ModelContainer
  
  init(modelContainer: ModelContainer) {
    self.modelContainer = modelContainer
  }
  
  func synchronizeWithServer() async {
    do {
      print("Syncing...")
      let modelContext = ModelContext(modelContainer)
      let gameDatasFromServer = [await ConnectionsApi.fetchBy(id: 0)]
      
      let models = try modelContext.fetch(FetchDescriptor<Game>())
      let persistedIds = Set(models.map(\.id))
      let newGameDatas = gameDatasFromServer.filter { !persistedIds.contains($0!.id) }
      
      for gameData in newGameDatas {
        modelContext.insert(Game(from: gameData))
      }
      try modelContext.save()
    } catch {
      print("Error syncing")
    }
  }
}
