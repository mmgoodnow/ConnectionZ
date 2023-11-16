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
  
  static func from(json: String) -> GameData {
    return try! JSONDecoder().decode(GameData.self, from: json.data(using: .utf8)!)
  }
}

@Observable class Group: Identifiable {
  let name: String
  let level: Int
  let words: Set<String>
  var found = false
  
  var id: String {
    return name
  }
  
  init(name: String, level: Int, words: Set<String>) {
    self.name = name
    self.level = level
    self.words = Set(words)
  }
  
  func emoji() -> String {
    switch (level) {
    case 0: return "🟨"
    case 1: return "🟩"
    case 2: return "🟦"
    case 3: return "🟪"
    default: return "⬛️"
    }
  }
  
  func score(of guess: Set<String>) -> Int {
    return self.words.intersection(guess).count
  }
}

@Observable class Guess: Identifiable {
  let words: Set<String>
  let score: Int
  
  var id: Set<String> { return words }
  
  init(words: Set<String>, score: Int) {
    self.words = words
    self.score = score
  }
}

@Observable class Game: Identifiable {
  let id: Int
  var words: [String]
  let groups: [Group]
  var guesses = [Guess]()
  
  init(id: Int, words: [String], groups: [Group]) {
    self.id = id
    self.words = words
    self.groups = groups
  }
  
  var foundGroups: [Group] {
    let correctGuesses = guesses.filter{ guess in return guess.score == 4}
    return correctGuesses.map { guess in
      return groups.first { group in return group.words == guess.words }!
    }
  }
  
  var numFoundGroups: Int {
    return foundGroups.count
  }
  
  var isComplete: Bool {
    return self.words.isEmpty
  }
  
  static func from(gameData: GameData) -> Game {
    let words = gameData.startingGroups.flatMap {$0}
    let groups = gameData.groups.map { (groupName, groupData) in
      return Group(name: groupName, level: groupData.level, words: Set(groupData.members))
    }
    return Game(id: gameData.id, words: words, groups: groups)
  }
  
  func guess(words candidates: Set<String>) -> Void {
    if guesses.contains(where: { $0.words == candidates }) {
      return;
    }
    
    let closestGroup: Group = self.groups.reduce(self.groups[0]) {acc, cur in
      let accCount = acc.score(of: candidates)
      let curCount = cur.score(of: candidates)
      return curCount > (accCount) ? cur : acc;
    }
    
    if closestGroup.score(of: candidates) == 4 {
      closestGroup.found = true;
      self.words = self.words.filter { !closestGroup.words.contains($0) }
    }
    
    guesses.append(Guess(words: candidates, score: closestGroup.score(of: candidates)))
  }
  
  func guess(row indices: Range<Int>) {
    return self.guess(words: Set(self.words[indices]))
  }
  
  func shuffle() {
    self.words.shuffle()
  }
  
  func emojis() -> String {
    let emojis = guesses.map { guess in
      guess.words.sorted().map { word in
        self.groups.first { $0.words.contains(word) }!.emoji()
      }.joined(separator: "")
    }.joined(separator: "\n")
    return "ConnectionZ\nPuzzle #\(self.id)\n\(emojis)"
  }
}
