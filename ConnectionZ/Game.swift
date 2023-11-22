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

func gameIdFor(date: Date) -> Int {
  var dateComponents = DateComponents()
  dateComponents.year = 2023
  dateComponents.month = 6
  dateComponents.day = 12
  let gameZero = Calendar(identifier: .gregorian).date(from: dateComponents)!
  return Calendar.current.dateComponents([.day], from: gameZero , to: date).day!
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

struct Group: Codable {
  let name: String
  let level: Int
  let words: Set<String>
  
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

struct Guess: Codable {
  let words: Set<String>
  let score: Int
  
  var id: Set<String> { return words }
  
  init(words: Set<String>, score: Int) {
    self.words = words
    self.score = score
  }
}

@Model class Game {
  let id: Int
  var words: [String]
  let groups: [Group]
  var guesses = [Guess]()
  
  init(id: Int, words: [String], groups: [Group]) {
    self.id = id
    self.words = words
    self.groups = groups
  }
  
  convenience init(from gameData: GameData) {
    let words = gameData.startingGroups.flatMap {$0}
    let groups = gameData.groups.map { (groupName, groupData) in
      return Group(name: groupName, level: groupData.level, words: Set(groupData.members))
    }
    self.init(id: gameData.id, words: words, groups: groups)
  }
  
  var name: String {
    return "Puzzle #\(id + 1)"
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
  
  var emojis: String {
    let emojis = guesses.map { guess in
      guess.words.sorted().map { word in
        self.groups.first { $0.words.contains(word) }!.emoji()
      }.joined(separator: "")
    }.joined(separator: "\n")
    return ["ConnectionZ", self.name, emojis].joined(separator: "\n")
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
  
  func reset() {
    self.guesses.removeAll()
  }
}
