//
//  ConnectionsApi.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/10/23.
//

import Foundation

struct ConnectionsApi {
  static func fetchBy(date: String) async -> GameData? {
    // Try v2 first (newer format, including special puzzles)
    if let gameData = await fetchFromApi(version: "v2", date: date) {
      return gameData
    }
    
    // Fall back to v1 if v2 fails
    return await fetchFromApi(version: "v1", date: date)
  }
  
  private static func fetchFromApi(version: String, date: String) async -> GameData? {
    let url = URL(string: "https://www.nytimes.com/svc/connections/\(version)/\(date).json")!
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      return try JSONDecoder().decode(GameData.self, from: data)
    } catch {
      print("Error fetching puzzle from \(version) API: \(error)")
      return nil
    }
  }
  
  // We need to add this method since it was referenced in BackgroundImporter
  static func fetchBy(id: Int) async -> GameData? {
    // If we have a specific ID, we can try to fetch today's puzzle
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateFormatter.string(from: Date())
    return await fetchBy(date: today)
  }
}
