//
//  Dates.swift
//  ConnectionZ
//
//  Created by Michael Goodnow on 11/22/23.
//

import Foundation

private let Gregorian = Calendar(identifier: .gregorian)
private let GAME_ZERO_COMPONENTS = DateComponents(year: 2023, month: 6, day: 11)
private let GAME_ZERO = Gregorian.date(from: GAME_ZERO_COMPONENTS)!

extension Date {
  func add(days: Int) -> Date {
    return Gregorian.date(byAdding: .day, value: days, to: self)!
  }
  
  func iso8601() -> String {
    return self.ISO8601Format(.iso8601Date(timeZone: .autoupdatingCurrent))
  }
  
  func snapToDay() -> Date {
    return Gregorian.date(from: Gregorian.dateComponents([.year, .month, .day], from: self))!
  }
  
  func humanReadableDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
    return dateFormatter.string(from: self)
  }
  
  init(iso8601: String) {
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = .autoupdatingCurrent
    formatter.formatOptions = [.withFullDate]
    self = formatter.date(from: iso8601)!
  }
}

struct DateSequence: Sequence {
  let startDate: Date
  
  func makeIterator() -> DateIterator {
    return DateIterator(self)
  }
}

struct DateIterator: IteratorProtocol {
  let dateSequence: DateSequence
  var days = 0
  
  
  init(_ dateSequence: DateSequence) {
    self.dateSequence = dateSequence
  }
  
  
  mutating func next() -> Date? {
    let nextDate = dateSequence.startDate.add(days: -days)
    guard Game.puzzleNumber(for: nextDate) > 0 else {
      return nil
    }
    days += 1
    return nextDate
  }
}

extension Game {
  static func puzzleNumber(for date: Date) -> Int {
    return Gregorian.dateComponents([.day], from: GAME_ZERO, to: date).day!
  }
  
  static func dateStr(for id: Int) -> String {
    return GAME_ZERO.add(days: id).ISO8601Format(.iso8601Date(timeZone: .autoupdatingCurrent))
  }
  
  var isPublished: Bool {
    return Date(iso8601: self.date) <= Date()
  }
}
