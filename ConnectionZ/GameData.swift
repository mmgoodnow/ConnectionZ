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

struct Card: Codable {
  let position: Int
  let content: String?
  let image_url: String?
  let image_alt_text: String?
}

struct CategoryData: Codable {
  let title: String
  let cards: [Card]
}

struct GameData: Codable {
  let id: Int
  let print_date: String?
  let editor: String?
  let status: String?
  
  // v1 API format
  let groups: Dictionary<String, GroupData>?
  let startingGroups: [[String]]?
  
  // v2 API format
  let categories: [CategoryData]?
  
  // Helper computed properties
  var isImageBasedPuzzle: Bool {
    return categories != nil
  }
  
  // Convert v2 format to v1 format
  var processedGroups: Dictionary<String, GroupData> {
    if let groups = groups {
      return groups
    } else if let categories = categories {
      var result = Dictionary<String, GroupData>()
      for (index, category) in categories.enumerated() {
        let members = category.cards.map { $0.image_alt_text ?? $0.content ?? "Unknown" }
        result[category.title] = GroupData(level: index, members: members)
      }
      return result
    }
    return [:]
  }
  
  // Convert v2 format to v1 format
  var processedStartingGroups: [[String]] {
    if let startingGroups = startingGroups {
      return startingGroups
    } else if let categories = categories {
      // Create a position-based array of all cards
      var allCards = [Card]()
      for category in categories {
        allCards.append(contentsOf: category.cards)
      }
      
      // Sort by position
      allCards.sort { $0.position < $1.position }
      
      // Group into rows of 4
      var result: [[String]] = []
      for i in stride(from: 0, to: allCards.count, by: 4) {
        let endIndex = min(i + 4, allCards.count)
        let row = allCards[i..<endIndex].map { $0.image_alt_text ?? $0.content ?? "Unknown" }
        result.append(Array(row))
      }
      
      return result
    }
    return []
  }
  
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
