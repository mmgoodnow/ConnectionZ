//
//  StatsView.swift
//  ConnectionZ
//
//  Created by Michael Goodnow on 1/27/25.
//

import Foundation
import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
	@Query(sort: \Game.date) private var persistedGames: [Game]
	
	var completedGames: [Game] {
		persistedGames.filter(\.isComplete)
	}
	
	var binnedData: [(
		index: Int,
		range: ChartBinRange<Int>,
		frequency: Int
	)] {
		let completedGames = self.completedGames.filter { $0.guesses.count <= 10 }
		let counts = completedGames.map(\.guesses.count)
		let bins = NumberBins(
			data: counts,
			desiredCount: 7
		)
		
		let groups: [Int: [Int]] = Dictionary(
			grouping: counts,
			by: { bins.index(for: $0) }
		)
		
		let preparedData = groups.map { key, values in
			return (
				index: key,
				range: bins[key],
				frequency: values.count
			)
		}
		
		return preparedData
	}
	
	var body: some View {
		List {
			Section {
				HStack {
					Text("Games Downloaded")
					Spacer()
					Text("\(persistedGames.count)")
				}
				HStack {
					Text("Games Completed")
					Spacer()
					Text("\(completedGames.count)")
				}
				HStack {
					Text("Perfect Score")
					Spacer()
					Text("\(completedGames.filter(\.isPerfectScore).count)")
				}
				HStack {
					Text("Purples First")
					Spacer()
					Text("\(completedGames.filter(\.gotPurplesFirst).count)")
				}
			}
			
			Section("Completion Histogram") {
				Chart(self.binnedData, id: \.index) { element in
					BarMark(
						x: .value(
							"Guesses",
							element.range
						),
						y: .value(
							"Frequency",
							element.frequency
						)
					)
				}
				.chartXScale(domain: 4...11)
				.padding(.vertical)
			}
		}
	}
	
}



#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: Game.self, configurations: config)
	
	let gameData = GameData(json: "{\"id\":151,\"groups\":{\"DOCTORS’ ORDERS\":{\"level\":0,\"members\":[\"DIET\",\"EXERCISE\",\"FRESH AIR\",\"SLEEP\"]},\"EMAIL ACTIONS\":{\"level\":1,\"members\":[\"COMPOSE\",\"FORWARD\",\"REPLY ALL\",\"SEND\"]},\"PODCASTS\":{\"level\":2,\"members\":[\"RADIOLAB\",\"SERIAL\",\"UP FIRST\",\"WTF\"]},\"___ COMEDY\":{\"level\":3,\"members\":[\"BLACK\",\"DIVINE\",\"PROP\",\"SKETCH\"]}},\"startingGroups\":[[\"COMPOSE\",\"DIVINE\",\"EXERCISE\",\"SEND\"],[\"FRESH AIR\",\"FORWARD\",\"SERIAL\",\"SKETCH\"],[\"WTF\",\"PROP\",\"UP FIRST\",\"DIET\"],[\"BLACK\",\"RADIOLAB\",\"SLEEP\",\"REPLY ALL\"]]}")
	let game = Game(from: gameData, on: "2023-09-09")
	_ = game.guess(words: Set(["RADIOLAB", "UP FIRST", "WTF", "FORWARD"]))
	_ = game.guess(words: Set(["RADIOLAB", "UP FIRST", "WTF", "REPLY ALL"]))
	_ = game.guess(words: Set(["RADIOLAB", "UP FIRST", "WTF", "SERIAL"]))
	_ = game.guess(words: Set(["FORWARD", "COMPOSE", "REPLY ALL", "SEND"]))
	_ = game.guess(words: Set(["FORWARD", "COMPOSE", "REPLY ALL", "SEND"]))
	_ = game.guess(words: Set(["DIVINE", "PROP", "BLACK", "SKETCH"]))
	_ = game.guess(words: Set(["EXERCISE", "FRESH AIR", "DIET", "SLEEP"]))
	container.mainContext.insert(game)
	return StatsView()
		.modelContainer(container)
}
