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

struct CompletedGroup: View {
  let group: Group
  
  func color() -> Color {
    switch (group.level) {
    case 0: return Color(.displayP3, red: 245/256, green: 224/256, blue: 126/256)
    case 1: return Color(.displayP3, red: 167/256, green: 194/256, blue: 104/256)
    case 2: return Color(.displayP3, red: 180/256, green: 195/256, blue: 235/256)
    case 3: return Color(.displayP3, red: 178/256, green: 131/256, blue: 193/256)
    default: return Color.black
    }
  }
  
  var body: some View {
    VStack {
      Text(group.name).font(.title).bold().foregroundStyle(.black)
      Text(group.words.sorted().joined(separator: ", ")).foregroundStyle(.black)
    }
    .frame(width: 430, height: 100)
    .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(color()))
    .foregroundStyle(.white)
    
  }
}

struct CompletedGroups: View {
  let groups: [Group]
  var body: some View {
    ForEach(groups) { group in
      CompletedGroup(group: group)
    }
  }
}

struct GuessView: View {
  let i: Int
  let guess: Guess
  
  var icon: String {
    if guess.score == 4 {
      return "star"
    } else if guess.score == 3 {
      return "circle.fill"
    } else {
      return "circle"
    }
  }
  
  var body: some View {
    GridRow {
      Label(guess.words.sorted().joined(separator: ", "), systemImage: icon).font(.headline)
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
  
  var body: some View {
    VStack {
      CompletedGroups(groups: game.foundGroups)
      LazyVGrid(columns: cols, content: {
        ReorderableForEach(items: game.words) { word in
          Tile(word: word)
        } moveAction: { from, to in
          game.words.move(fromOffsets: from, toOffset: to)
        }
      })
      HStack {
        Button("Guess Top Row") {
          game.guess(row: 0..<4)
        }.buttonStyle(.bordered)
        
        Button("Shuffle") {
          game.shuffle()
        }.buttonStyle(.bordered)
      }.padding()
      Grid(alignment: .leading) {
        ForEach(Array(game.guesses.enumerated()), id: \.offset) {
          i, guess in
          GuessView(i: i, guess: guess)
        }
      }.padding()
    }.padding()
  }
}

#Preview {
  let gameData = GameData.from(json: "{\"id\":150,\"groups\":{\"DOCTORS’ ORDERS\":{\"level\":0,\"members\":[\"DIET\",\"EXERCISE\",\"FRESH AIR\",\"SLEEP\"]},\"EMAIL ACTIONS\":{\"level\":1,\"members\":[\"COMPOSE\",\"FORWARD\",\"REPLY ALL\",\"SEND\"]},\"PODCASTS\":{\"level\":2,\"members\":[\"RADIOLAB\",\"SERIAL\",\"UP FIRST\",\"WTF\"]},\"___ COMEDY\":{\"level\":3,\"members\":[\"BLACK\",\"DIVINE\",\"PROP\",\"SKETCH\"]}},\"startingGroups\":[[\"COMPOSE\",\"DIVINE\",\"EXERCISE\",\"SEND\"],[\"FRESH AIR\",\"FORWARD\",\"SERIAL\",\"SKETCH\"],[\"WTF\",\"PROP\",\"UP FIRST\",\"DIET\"],[\"BLACK\",\"RADIOLAB\",\"SLEEP\",\"REPLY ALL\"]]}")
  var game = Game.from(gameData: gameData)
  game.guess(words: Set(["RADIOLAB", "UP FIRST", "WTF", "SERIAL"]))
  game.guess(words: Set(["FORWARD", "COMPOSE", "REPLY ALL", "SEND"]))
  return GameView(game: game)
}
