//
//  ConnectionZTests.swift
//  ConnectionZTests
//
//  Created by Michael Goodnow on 3/16/24.
//

import XCTest
@testable import ConnectionZ

final class ConnectionZTests: XCTestCase {
    func testDates() throws {
      let x = Game.puzzleNumber(for: Date(iso8601: "2024-03-10"))
      let y = Game.puzzleNumber(for: Date(iso8601: "2024-03-11"))
      XCTAssertEqual(x, 273)
      XCTAssertEqual(y, 274)
    }
}
