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
      .multilineTextAlignment(.center)
      .lineLimit(1)
      .minimumScaleFactor(0.5)
      .padding(8)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .aspectRatio(1, contentMode: .fill)
      .foregroundStyle(.black)
      .bold()
      .background(
        RoundedRectangle(
          cornerSize: CGSize(width: 10, height: 10)
        )
        .fill(Color.white)
        .fill(
          Color(
            .displayP3,
            red: 239/256,
            green: 238/256,
            blue: 231/256
          )
        )
      )
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
      Text(group.name).font(.title2).bold().foregroundStyle(.black)
      Text(group.words.sorted().joined(separator: ", ")).foregroundStyle(.black)
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    .aspectRatio(4, contentMode: .fit)
    .background(
      RoundedRectangle(
        cornerSize: CGSize(
          width: 10,
          height: 10
        )
      ).fill(color()))
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
      return "star.fill"
    } else if guess.score == 3 {
      return "circle.fill"
    } else {
      return "circle"
    }
  }
  
  var body: some View {
    GridRow {
      Label(guess.words.sorted().joined(separator: ", "), systemImage: icon)
    }
  }
}

struct GameView: View {
  let cols = [
    GridItem(.flexible(), spacing: 8),
    GridItem(.flexible(), spacing: 8),
    GridItem(.flexible(), spacing: 8),
    GridItem(.flexible(), spacing: 8)
  ]
  var game: Game
  
  var body: some View {
    VStack {
      Text("Create four groups of four!").font(.title2)
      Grid(alignment: .leading) {
        ForEach(Array(game.guesses.enumerated()), id: \.offset) {
          i, guess in
          GuessView(i: i, guess: guess)
        }
      }.padding(.vertical)
      CompletedGroups(groups: game.foundGroups)
      LazyVGrid(columns: cols, content: {
        ReorderableForEach(items: game.words) { word in
          Tile(word: word)
        } moveAction: { from, to in
          game.words.move(fromOffsets: from, toOffset: to)
        }
      })
      HStack {
        if game.isComplete {
          HStack {
            Text("Complete!").font(.largeTitle)
            Button("Copy Results") {
              copyToClipboard(game.emojis())
            }.buttonStyle(.bordered)
          }
        } else {
          Button("Guess Top Row") {
            game.guess(row: 0..<4)
          }.buttonStyle(.bordered)
          Button("Shuffle") {
            game.shuffle()
          }.buttonStyle(.bordered)
        }
      }.padding(.vertical)
    }.padding()
  }
}

#Preview {
  let gameData = GameData.from(json: "{\"id\":150,\"groups\":{\"DOCTORS’ ORDERS\":{\"level\":0,\"members\":[\"DIET\",\"EXERCISE\",\"FRESH AIR\",\"SLEEP\"]},\"EMAIL ACTIONS\":{\"level\":1,\"members\":[\"COMPOSE\",\"FORWARD\",\"REPLY ALL\",\"SEND\"]},\"PODCASTS\":{\"level\":2,\"members\":[\"RADIOLAB\",\"SERIAL\",\"UP FIRST\",\"WTF\"]},\"___ COMEDY\":{\"level\":3,\"members\":[\"BLACK\",\"DIVINE\",\"PROP\",\"SKETCH\"]}},\"startingGroups\":[[\"COMPOSE\",\"DIVINE\",\"EXERCISE\",\"SEND\"],[\"FRESH AIR\",\"FORWARD\",\"SERIAL\",\"SKETCH\"],[\"WTF\",\"PROP\",\"UP FIRST\",\"DIET\"],[\"BLACK\",\"RADIOLAB\",\"SLEEP\",\"REPLY ALL\"]]}")
  var game = Game.from(gameData: gameData)
//  game.guess(words: Set(["RADIOLAB", "UP FIRST", "WTF", "SERIAL"]))
//  game.guess(words: Set(["FORWARD", "COMPOSE", "REPLY ALL", "SEND"]))
//  game.guess(words: Set(["DIVINE", "PROP", "BLACK", "SKETCH"]))
//  game.guess(words: Set(["EXERCISE", "FRESH AIR", "DIET", "SLEEP"]))
  return GameView(game: game)
}
