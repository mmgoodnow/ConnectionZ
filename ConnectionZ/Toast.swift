//
//  Toast.swift
//  ConnectionZ
//
//  Created by Michael Goodnow on 2/25/24.
//

import Foundation
import SwiftUI
import Drops

struct Toast {
  static func copied() -> Void {
#if os(iOS)
    Drops.show(
      Drop(
        title:"Copied!", icon: UIImage(systemName: "paperclip")
      )
    )
#endif
  }
  
  static func alreadyGuessed() -> Void {
#if os(iOS)
    Drops.show(
      Drop(
        title: "Already guessed!", icon: UIImage(systemName:"repeat")
      )
    )
#endif
  }
  
  static func oneAway() -> Void {
#if os(iOS)
    Drops.show(
      Drop(
        title: "One away!", icon: UIImage(systemName: "3.square")
      )
    )
#endif
  }
}
