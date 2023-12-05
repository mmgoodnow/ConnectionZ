//
//  Color.swift
//  ConnectionZ
//
//  Created by Michael Goodnow on 12/5/23.
//

import Foundation
import SwiftUI

public extension Color {
#if os(macOS)
  static let background = Color(NSColor.windowBackgroundColor)
  static let secondaryBackground = Color(NSColor.controlBackgroundColor)
#else
  static let background = Color(UIColor.systemBackground)
  static let secondaryBackground = Color(UIColor.secondarySystemBackground)
#endif
}
