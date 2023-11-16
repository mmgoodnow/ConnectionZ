//
//  Clipboard.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/16/23.
//

import Foundation
import AppKit

func copyToClipboard(_ str: String) -> Void {
#if os(iOS)
  UIPasteboard.general.string = str
#endif
#if os(macOS)
  let pasteboard = NSPasteboard.general
  pasteboard.declareTypes([.string], owner: nil)
  pasteboard.setString(str, forType: .string)
#endif
}
