//
//  Dates.swift
//  ConnectionZ
//
//  Created by Michael Goodnow on 11/22/23.
//

import Foundation

private let Gregorian = Calendar(identifier: .gregorian)
private let GAME_ZERO_COMPONENTS = DateComponents(year: 2023, month: 6, day: 12)
private let GAME_ZERO = Gregorian.date(from: GAME_ZERO_COMPONENTS)!

extension Date {
  func add(days: Int) -> Date {
    return Gregorian.date(byAdding: .day, value: days, to: self)!
  }
}

extension Game {
  static func id(for date: Date) -> Int {
    return Gregorian.dateComponents([.day], from: GAME_ZERO, to: date).day!
  }
  
  var date: Date {
    let date = Gregorian.date(byAdding: .day, value: self.id, to: GAME_ZERO)!
    return Gregorian.startOfDay(for: date)
  }
  
  var isPublished: Bool {
    return self.date < Date()
  }
}
