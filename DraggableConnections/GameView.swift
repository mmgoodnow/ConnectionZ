//
//  GameView.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/11/23.
//

import Foundation
import SwiftUI

extension String: Identifiable {
  public typealias ID = Int
  public var id: Int {
    return hash
  }
}

struct Tile: View {
  var word: String
  var isSelected: Bool
  var onSelect: (String) -> Void
  
  var body: some View {
    if (isSelected) {
      Text(word)
        .fixedSize(horizontal: true, vertical: true)
        .multilineTextAlignment(.center)
        .padding()
        .frame(width: 100, height: 100)
        .foregroundStyle(.black)
        .bold()
        .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.white))
        .colorInvert()
    } else {
      Text(word)
        .fixedSize(horizontal: true, vertical: true)
        .multilineTextAlignment(.center)
        .padding()
        .frame(width: 100, height: 100)
        .foregroundStyle(.black)
        .bold()
        .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.white))
    }
  }
}

struct GameView: View {
  let cols = [
    GridItem(.fixed(100), spacing: 10),
    GridItem(.fixed(100), spacing: 10),
    GridItem(.fixed(100), spacing: 10),
    GridItem(.fixed(100), spacing: 10)
  ]
  var game: Game
  
  init(gameData: GameData) {
    self.game = Game.from(gameData: gameData)
  }
  
  var body: some View {
    LazyVGrid(columns: cols, content: {
      ReorderableForEach(items: game.words) { word in
        Tile(word: word, isSelected: game.selected.contains(word), onSelect: { game.select($0) })
      } moveAction: { from, to in
        game.words.move(fromOffsets: from, toOffset: to)
      } clickAction: { i in
        game.select(at: i)
      }
    })
  }
}
