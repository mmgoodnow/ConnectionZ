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

@Observable class Group {
  let name: String
  let level: Int
  let words: Set<String>
  var found = false
  
  init(name: String, level: Int, words: Set<String>) {
    self.name = name
    self.level = level
    self.words = Set(words)
  }
  
  func score(of guess: Set<String>) -> Int {
    return self.words.intersection(guess).count
  }
}

@Observable class Game: Identifiable {
  let id: Int
  var words: [String]
  let groups: [Group]
  var selected = Set<String>()
  var guesses = [(Set<String>, Int)]()
  
  init(id: Int, words: [String], groups: [Group]) {
    self.id = id
    self.words = words
    self.groups = groups
  }
  
  static func from(gameData: GameData) -> Game {
    let words = gameData.startingGroups.flatMap {$0}
    let groups = gameData.groups.map { (groupName, groupData) in
      return Group(name: groupName, level: groupData.level, words: Set(groupData.members))
    }
    return Game(id: gameData.id, words: words, groups: groups)
  }
  
  func guess(words candidates: Set<String>) -> Void {
    let closestGroup: Group = self.groups.reduce(self.groups[0]) {acc, cur in
      let accCount = acc.score(of: candidates)
      let curCount = cur.score(of: candidates)
      return curCount > (accCount) ? cur : acc;
    }
    
    if closestGroup.score(of: candidates) == 4 {
      closestGroup.found = true;
      self.words = self.words.filter { closestGroup.words.contains($0) }
    }
    guesses.append((candidates, closestGroup.score(of: candidates)))
  }
  
  func select(_ word: String) -> Void {
    if self.selected.contains(word) {
      self.selected.remove(word);
    } else if selected.count < 4 {
      self.selected.insert(word);
    }
  }
  
  func select(at i: Int) -> Void {
    return self.select(words[i])
  }
}
