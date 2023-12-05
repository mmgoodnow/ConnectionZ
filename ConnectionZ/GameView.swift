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
      .minimumScaleFactor(0.1)
      .padding(8)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .aspectRatio(1, contentMode: .fit)
      .bold()
      .background(
        RoundedRectangle(
          cornerSize: CGSize(width: 10, height: 10)
        )
        .fill(
          Color.secondaryBackground
        )
      )
  }
}

struct CompletedGroup: View {
  let group: Group
  
  var color: Color {
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
    .background(
      RoundedRectangle(
        cornerSize: CGSize(
          width: 10,
          height: 10
        )
      ).fill(color))
  }
}

struct CompletedGroups: View {
  let groups: [Group]
  var body: some View {
    ForEach(groups, id: \.name) { group in
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

struct GuessesView: View {
  var guesses: [Guess]
  var body: some View {
    Text("Guesses").font(.title3)
    ScrollView {
      Grid(alignment: .leading) {
        ForEach(Array(guesses.enumerated()), id: \.offset) {
          i, guess in
          GuessView(i: i, guess: guess)
        }
      }.padding()
    }
    .defaultScrollAnchor(.bottom)
    .frame(maxWidth: 500, maxHeight: .infinity)
    .background(
      RoundedRectangle(
        cornerSize: CGSize(width: 10, height: 10)
      )
      .fill(Color.secondaryBackground)
    )
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
      GuessesView(guesses: game.guesses)
      if game.isComplete {
        Text("Complete!").font(.title2)
      } else {
        Text("Create four groups of four!").font(.title2)
      }
      VStack(spacing: 8) {
        CompletedGroups(groups: game.foundGroups)
        LazyVGrid(columns: cols, spacing: 8, content: {
          ReorderableForEach(items: game.words) { word in
            Tile(word: word)
          } moveAction: { from, to in
            game.words.move(fromOffsets: from, toOffset: to)
          }
        })
      }
      .frame(minWidth: 300, maxWidth: 500, minHeight: 300, maxHeight: 500)
      .aspectRatio(1, contentMode: .fit)
      .layoutPriority(1)
      HStack {
        if game.isComplete {
          Button("Copy Results") {
            copyToClipboard(game.emojis)
          }.buttonStyle(.bordered)
        } else {
          Button("Guess Top Row") {
            withAnimation {
              game.guess(row: 0..<4)
            }
          }.buttonStyle(.bordered)
          Button("Shuffle") {
            game.shuffle()
          }.buttonStyle(.bordered)
        }
      }
      .padding(.top)
    }
    .padding()
  }
}

#Preview {
  let gameData = GameData(json: "{\"id\":150,\"groups\":{\"DOCTORS’ ORDERS\":{\"level\":0,\"members\":[\"DIET\",\"EXERCISE\",\"FRESH AIR\",\"SLEEP\"]},\"EMAIL ACTIONS\":{\"level\":1,\"members\":[\"COMPOSE\",\"FORWARD\",\"REPLY ALL\",\"SEND\"]},\"PODCASTS\":{\"level\":2,\"members\":[\"RADIOLAB\",\"SERIAL\",\"UP FIRST\",\"WTF\"]},\"___ COMEDY\":{\"level\":3,\"members\":[\"BLACK\",\"DIVINE\",\"PROP\",\"SKETCH\"]}},\"startingGroups\":[[\"COMPOSE\",\"DIVINE\",\"EXERCISE\",\"SEND\"],[\"FRESH AIR\",\"FORWARD\",\"SERIAL\",\"SKETCH\"],[\"WTF\",\"PROP\",\"UP FIRST\",\"DIET\"],[\"BLACK\",\"RADIOLAB\",\"SLEEP\",\"REPLY ALL\"]]}")
  let game = Game(from: gameData)
//  game.guess(words: Set(["RADIOLAB", "UP FIRST", "WTF", "FORWARD"]))
//  game.guess(words: Set(["RADIOLAB", "UP FIRST", "WTF", "REPLY ALL"]))
//  game.guess(words: Set(["RADIOLAB", "UP FIRST", "WTF", "SERIAL"]))
//  game.guess(words: Set(["FORWARD", "COMPOSE", "REPLY ALL", "SEND"]))
//  game.guess(words: Set(["DIVINE", "PROP", "BLACK", "SKETCH"]))
//  game.guess(words: Set(["EXERCISE", "FRESH AIR", "DIET", "SLEEP"]))
  return GameView(game: game).frame(width: 300, height: 600)
}
