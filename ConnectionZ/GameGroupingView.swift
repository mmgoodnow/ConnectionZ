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
  var games: [Game]
  @State private var isExpanded: Bool
  
  init(sectionName: String, games: [Game], startCollapsed: Bool = false) {
    self.sectionName = sectionName
    self.games = games
    self.isExpanded = !startCollapsed
  }
  
  var body: some View {
    if (!games.isEmpty) {
      Section(sectionName, isExpanded: $isExpanded) {
        ForEach(games) { game in
          NavigationLink(game.name, value: game.id)
        }
      }
    }
  }
}
