//
//  ConnectionsApi.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/10/23.
//

import Foundation
import SwiftSoup

struct ConnectionsApi {
  static func parseGamesFromResponse(data: Data) -> [Game] {
    let document: Document = try! SwiftSoup.parse(String(data: data, encoding: .utf8)!)
    let scriptTags = try! document.select("script[type=\"text/javascript\"]")
    let js = try! scriptTags.first()!.html()
    let json = js.replacingOccurrences(of: "window.gameData = ", with: "")
    return try! JSONDecoder().decode([Game].self, from: json.data(using: .utf8)!)
  }
  
  static func fetchAllConnectionsGames() async -> [Game]  {
    let url = URL(string: "https://nytimes.com/games/connections")!
    let (data, _) = try! await URLSession.shared.data(from: url)
    return self.parseGamesFromResponse(data: data);
  }
}
