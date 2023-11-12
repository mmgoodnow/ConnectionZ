//
//  Game.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/10/23.
//

import Foundation
import SwiftData

struct GroupData: Codable {
  let level: Int
  let members: [String]
}

struct GameData: Codable, Identifiable {
  let id: Int
  let groups: Dictionary<String, GroupData>
  let startingGroups: [[String]]
  
  func toJsonString() -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode(self)
    return String(data: data, encoding: .utf8)!
  }
}

@Model class Group {
  let name: String
  let level: Int
  let words: [String]
  
  init(name: String, level: Int, words: [String]) {
    self.name = name
    self.level = level
    self.words = words
  }
}

@Model class Game: Identifiable {
  let id: Int
  var words: [String]
  let groups: [Group]
  
  init(id: Int, words: [String], groups: [Group]) {
    self.id = id
    self.words = words
    self.groups = groups
  }
  
  static func from(gameData: GameData) -> Game {
    let words = gameData.startingGroups.flatMap {$0}
    let groups = gameData.groups.map { (groupName, groupData) in
      return Group(name: groupName, level: groupData.level, words: groupData.members)
    }
    return Game(id: gameData.id, words: words, groups: groups)
  }
}
