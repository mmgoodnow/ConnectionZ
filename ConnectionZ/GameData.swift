//
//  GameData.swift
//  ConnectionZ
//
//  Created by Michael Goodnow on 11/22/23.
//

import Foundation

struct GroupData: Codable {
  let level: Int
  let members: [String]
}

struct GameData: Codable {
  let id: Int
  let groups: Dictionary<String, GroupData>
  let startingGroups: [[String]]
  
  func toJsonString() -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode(self)
    return String(data: data, encoding: .utf8)!
  }
  
  init(json: String) {
    self = try! JSONDecoder().decode(GameData.self, from: json.data(using: .utf8)!)
  }
}
