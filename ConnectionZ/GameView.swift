//
//  GameView.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/11/23.
//

import Foundation
import SwiftUI
import Drops

extension String: Identifiable {
  public typealias ID = Int
  public var id: Int {
    return hash
  }
}

extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}

enum Swipe {
  case up
  case down
  case left
  case right
}

struct Tile: View {
  var word: String
  var selected: Bool
  var selectAction: () -> Void
  
  var borderWidth: CGFloat {
    return selected ? 4 : 0
  }
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
        .fill(Color.secondaryBackground)
        .addBorder(Color.accentColor, width: borderWidth, cornerRadius: 10)
      ).onTapGesture(perform: selectAction)

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
      return "4.square.fill"
    } else if guess.score == 3 {
      return "3.square"
    } else {
      return "square"
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
  @State var selected = Set<String>()
  @State var shouldShowConfirmationDialog = false;
  
  func select(word: String) {
    if selected.contains(word) {
      selected.remove(word)
    } else if selected.count < 4 {
      selected.insert(word)
    }
  }
  
  func onSwipe(direction: Swipe) {
    if direction == .up {

    } else if direction == .down {

    }
  }

  func isSelected(word: String) -> Bool {
    return selected.contains(word)
  }
  
  var guessButtonText: String {
    return selected.count == 4 ? "Guess Selection" : "Guess Top Row"
  }
  
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
            Tile(word: word, selected: isSelected(word: word), selectAction: {
              select(word: word)
            })
          } moveAction: { from, to in
            game.words.move(fromOffsets: from, toOffset: to)
          }
        }).gesture(DragGesture(minimumDistance: 20, coordinateSpace: .local).onEnded { value in
          if abs(value.translation.height) > abs(value.translation.width) {
            game.onMove(words: selected, direction: value.translation.height.sign == .minus ? -1 : 1)
          }
      })
      }
      .frame(minWidth: 300, maxWidth: 500, minHeight: 300, maxHeight: 500)
      .aspectRatio(1, contentMode: .fit)
      .layoutPriority(1)
      HStack {
        if game.isComplete {
          Spacer()
          Button("Copy Results") {
            copyToClipboard(game.emojis)
            Toast.copied()
          }.buttonStyle(.bordered)
          Spacer()
          Button("Reset Game") {
            shouldShowConfirmationDialog = true
          }.buttonStyle(.bordered)
            .confirmationDialog(
              "Resetting will delete this game's history.",
              isPresented: $shouldShowConfirmationDialog
            ) {
              Button("Reset Game", role: .destructive) {
                game.reset()
              }.keyboardShortcut(.defaultAction)
              Button("Cancel", role: .cancel, action: {})
                .keyboardShortcut(.cancelAction)
            }
          Spacer()
        } else {
          Spacer()
          Button("Deselect All") {
            selected.removeAll()
          }.buttonStyle(.bordered)
          Spacer()
          Button("Shuffle") { game.words.shuffle() }.buttonStyle(.bordered)
          Spacer()
          Button(guessButtonText) {
            withAnimation {
              let guessResult = 
              selected.count == 4 ?
                game.guess(words: selected) :
                game.guess(row: 0..<4)
              switch guessResult {
              case .alreadyGuessed:
                Toast.alreadyGuessed()
              case .oneAway:
                Toast.oneAway()
              case .correct:
                selected.removeAll()
              case .incorrect:
                break
              }
            }
          }.buttonStyle(.bordered)
          Spacer()
        }
      }
      .padding(.top)
    }
    .padding()
  }
}

#Preview {
  let gameData = GameData(json: "{\"id\":151,\"groups\":{\"DOCTORS’ ORDERS\":{\"level\":0,\"members\":[\"DIET\",\"EXERCISE\",\"FRESH AIR\",\"SLEEP\"]},\"EMAIL ACTIONS\":{\"level\":1,\"members\":[\"COMPOSE\",\"FORWARD\",\"REPLY ALL\",\"SEND\"]},\"PODCASTS\":{\"level\":2,\"members\":[\"RADIOLAB\",\"SERIAL\",\"UP FIRST\",\"WTF\"]},\"___ COMEDY\":{\"level\":3,\"members\":[\"BLACK\",\"DIVINE\",\"PROP\",\"SKETCH\"]}},\"startingGroups\":[[\"COMPOSE\",\"DIVINE\",\"EXERCISE\",\"SEND\"],[\"FRESH AIR\",\"FORWARD\",\"SERIAL\",\"SKETCH\"],[\"WTF\",\"PROP\",\"UP FIRST\",\"DIET\"],[\"BLACK\",\"RADIOLAB\",\"SLEEP\",\"REPLY ALL\"]]}")
  let game = Game(from: gameData, on: "2023-09-09")
//  game.guess(words: Set(["RADIOLAB", "UP FIRST", "WTF", "FORWARD"]))
//  game.guess(words: Set(["RADIOLAB", "UP FIRST", "WTF", "REPLY ALL"]))
//  game.guess(words: Set(["RADIOLAB", "UP FIRST", "WTF", "SERIAL"]))
//  game.guess(words: Set(["FORWARD", "COMPOSE", "REPLY ALL", "SEND"]))
//  game.guess(words: Set(["DIVINE", "PROP", "BLACK", "SKETCH"]))
//  game.guess(words: Set(["EXERCISE", "FRESH AIR", "DIET", "SLEEP"]))
  return GameView(game: game).frame(width: 300, height: 600)
}
