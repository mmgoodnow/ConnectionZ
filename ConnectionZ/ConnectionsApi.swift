//
//  ConnectionsApi.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/10/23.
//

import Foundation

struct ConnectionsApi {
  static func fetchBy(id: Int) async -> GameData? {
    let dateStr = Game.dateStr(for: id)
    print(dateStr)
    let url = URL(string: "https://www.nytimes.com/svc/connections/v1/\(dateStr).json")!
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      return try JSONDecoder().decode(GameData.self, from:data)
    } catch {
      return nil
    }
  }
}
