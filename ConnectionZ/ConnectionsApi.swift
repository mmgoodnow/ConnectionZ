//
//  ConnectionsApi.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/10/23.
//

import Foundation

struct ConnectionsApi {
  static func fetchBy(date: String) async -> GameData? {
    let url = URL(string: "https://www.nytimes.com/svc/connections/v1/\(date).json")!
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      return try JSONDecoder().decode(GameData.self, from:data)
    } catch {
      return nil
    }
  }
}
