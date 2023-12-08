//
//  GameGroupingView.swift
//  ConnectionZ
//
//  Created by Michael Goodnow on 11/22/23.
//

import Foundation
import SwiftUI

struct GameGroupingView: View {
  var sectionName: String
  var ids: [Int]
  @State private var isExpanded: Bool
  
  init(sectionName: String, ids: [Int], startCollapsed: Bool = false) {
    self.sectionName = sectionName
    self.ids = ids
    self.isExpanded = !startCollapsed
  }
  
  var body: some View {
    if (!ids.isEmpty) {
      Section(sectionName, isExpanded: $isExpanded) {
        ForEach(ids, id: \.self) { id in
          NavigationLink(Game.name(for: id), value: id)
        }
      }
    }
  }
}
