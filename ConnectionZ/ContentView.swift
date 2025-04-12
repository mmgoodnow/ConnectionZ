//
//  ContentView.swift
//  DraggableConnections
//
//  Created by Michael Goodnow on 11/9/23.
//

import SwiftUI
import SwiftData

extension Array where Element: Game {
	func by(date dateMaybe: String?) -> Game? {
		guard let date = dateMaybe else {
			return nil
		}
		return first { $0.date == date }
	}
}

struct ContentView: View {
	@State private var refreshTrigger = false
	@State private var showRedownloadAlert = false
	@State private var forceRedownloadDate: String?
	@Environment(\.colorScheme) private var colorScheme
	@SceneStorage("ContentView.selectedDate") private var selectedDate: String?
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Game.date) private var persistedGames: [Game]
	
	private func downloadSelectedGame(forceRedownload: Bool = false) async {
		if let date = selectedDate, date != "stats" {
			if forceRedownload || persistedGames.by(date: date) == nil {
				// If force redownload and game exists, delete it first
				if forceRedownload, let existingGame = persistedGames.by(date: date) {
					modelContext.delete(existingGame)
					try? modelContext.save()
				}
				
				print("Fetching puzzle \(date)")
				let response = await ConnectionsApi.fetchBy(date: date)
				if let gameData = response {
					print("Inserting puzzle \(gameData.id) - \(date)")
					modelContext.insert(Game(from: gameData, on: date))
					try? modelContext.save()
				}
			}
		}
	}
	
	var streakRepairDates: [Date] {
		guard let firstCompletedGame = persistedGames.first(where: \.isComplete) else {
			return []
		}
		
		let firstDate = Date(iso8601: firstCompletedGame.date)
		var dates = [Date]()
		for date in DateSequence(startDate: Date().snapToDay()) {
			if (date <= firstDate) {
				break;
			}
			if let persistedGame = persistedGames.by(date: date.iso8601()) {
				if (persistedGame.isComplete) {
					continue;
				}
			}
			dates.append(date)
		}
		return dates.reversed()
	}
	
	var body: some View {
		NavigationSplitView {
			List(selection: $selectedDate) {
				Section(header: Text("Current")) {
					NavigationLink("Today's Game", value: Date().iso8601())
					NavigationLink("Yesterday's Game", value: Date().add(days: -1).iso8601())
				}
				GameGroupingView(sectionName: "In Progress", dates: persistedGames.filter(\.isInProgress).map(\.date))
				GameGroupingView(sectionName: "Streak Repair", dates: streakRepairDates.map { $0.iso8601() })
				GameGroupingView(sectionName: "Completed", dates: persistedGames.filter(\.isComplete).map(\.date).reversed(), startCollapsed: true)
				GameGroupingView(
					sectionName: "Archive",
					dates: Array(DateSequence(startDate: Date().snapToDay())).map { $0.iso8601() },
					startCollapsed: true
				)
				Section(header: Text("Stats")) {
					NavigationLink("View Stats", value: "stats")
				}
			}.navigationTitle("ConnectionZ")
				.refreshable {
					refreshTrigger.toggle()
				}
				.contextMenu(forSelectionType: String.self) { items in
					if let selectedItems = items.first, selectedItems != "stats" {
						Button("Redownload Puzzle") {
							forceRedownloadDate = selectedItems
							showRedownloadAlert = true
						}
					}
				}
		} detail: {
			if selectedDate == "stats" {
				StatsView()
					.navigationTitle("Stats")
			} else
			if let game = persistedGames.by(date: selectedDate) {
				GameView(game: game)
					.navigationTitle(game.name)
#if os(iOS)
					.navigationBarTitleDisplayMode(.inline)
#endif
					.toolbar {
						ToolbarItem(placement: .secondaryAction) {
							Button("Redownload Puzzle") {
								forceRedownloadDate = selectedDate
								showRedownloadAlert = true
							}
						}
					}
			} else {
				Text("Select a game")
			}
		}
		.onChange(of: selectedDate, initial: true) {
			Task {
				await downloadSelectedGame()
			}
		}
		.alert("Redownload Puzzle", isPresented: $showRedownloadAlert) {
			Button("Cancel", role: .cancel) {}
			Button("Redownload", role: .destructive) {
				if let date = forceRedownloadDate {
					selectedDate = date
					Task {
						await downloadSelectedGame(forceRedownload: true)
					}
				}
			}
		} message: {
			Text("This will delete and redownload the puzzle. This is useful for puzzles like April 1st, 2025 that had a special format.")
		}
	}
}

