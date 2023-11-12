//
//  GameView.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/11/23.
//

import Foundation
import SwiftUI

struct Tile: View {
  var word: String
  
  var body: some View {
      Text(word)
          .fixedSize(horizontal: true, vertical: true)
          .multilineTextAlignment(.center)
          .padding()
          .frame(width: 100, height: 100)
          .foregroundStyle(.black)
          .bold()
          .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.white).shadow(radius: 3))
    }
}

struct GameView: View {
  var game: Game
  
  init(gameData: GameData) {
    self.game = Game.from(gameData: gameData)
  }
  
  var body: some View {
    Grid {
      GridRow {
        Tile(word: game.words[0])
        Tile(word: game.words[1])
        Tile(word: game.words[2])
        Tile(word: game.words[3])
      }
      GridRow {
        Tile(word: game.words[4])
        Tile(word: game.words[5])
        Tile(word: game.words[6])
        Tile(word: game.words[7])
      }
      GridRow {
        Tile(word: game.words[8])
        Tile(word: game.words[9])
        Tile(word: game.words[10])
        Tile(word: game.words[11])
      }
      GridRow {
        Tile(word: game.words[12])
        Tile(word: game.words[13])
        Tile(word: game.words[14])
        Tile(word: game.words[15])
      }
    }
  }
}
