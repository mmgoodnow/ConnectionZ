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
  
  var body: some View {
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

struct GuessButton: View {
  let guessAction: () -> Void
  
  var body: some View {
    Button("Guess", action: { guessAction() }).padding().frame(width: 100, height: 100)
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
    HStack {
      Spacer()
      LazyVGrid(columns: cols, content: {
        ReorderableForEach(items: game.words) { word in
          Tile(word: word)
        } moveAction: { from, to in
          game.words.move(fromOffsets: from, toOffset: to)
        }
      })
      VStack {
        GuessButton(guessAction: { game.guess(row: 0..<4) })
        GuessButton(guessAction: { game.guess(row: 4..<8) })
        GuessButton(guessAction: { game.guess(row: 8..<12) })
        GuessButton(guessAction: { game.guess(row: 12..<16) })
      }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}
