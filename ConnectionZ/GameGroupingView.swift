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
  var dates: [String]
  @State private var isExpanded: Bool
  
  init(sectionName: String, dates: [String], startCollapsed: Bool = false) {
    self.sectionName = sectionName
    self.dates = dates
    self.isExpanded = !startCollapsed
  }
  
  var body: some View {
    if (!dates.isEmpty) {
      Section(sectionName, isExpanded: $isExpanded) {
        ForEach(dates, id: \.self) { date in
          NavigationLink(Date(iso8601: date).humanReadableDate(), value: date)
        }
      }
    }
  }
}
