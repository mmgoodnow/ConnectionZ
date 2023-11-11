//
//  Game.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/10/23.
//

import Foundation


//{
//  "id": 0,
//  "groups": {
//    "WET WEATHER": {
//      "level": 0,
//      "members": ["HAIL", "RAIN", "SLEET", "SNOW"]
//    },
//    "NBA TEAMS": {
//      "level": 1,
//      "members": ["BUCKS", "HEAT", "JAZZ", "NETS"]
//    },
//    "KEYBOARD KEYS": {
//      "level": 2,
//      "members": ["OPTION", "RETURN", "SHIFT", "TAB"]
//    },
//    "PALINDROMES": {
//      "level": 3,
//      "members": ["KAYAK", "LEVEL", "MOM", "RACE CAR"]
//    }
//  },
//  "startingGroups": [
//    ["SNOW", "LEVEL", "SHIFT", "KAYAK"],
//    ["HEAT", "TAB", "BUCKS", "RETURN"],
//    ["JAZZ", "HAIL", "OPTION", "RAIN"],
//    ["SLEET", "RACE CAR", "MOM", "NETS"]
//  ]
//}

struct Group: Codable {
  let level: Int
  let members: [String]
}

struct Game: Codable {
  let id: Int
  let groups: Dictionary<String, Group>
  let startingGroups: [[String]]
}
