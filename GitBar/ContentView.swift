//
//  ContentView.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/6/25.
//

import SwiftUI
import Defaults

struct ContentView: View {
	@EnvironmentObject var commitFetcherService: CommitFetcherService
	@Default(.useRollingCount) private var useRollingCount
	@Default(.fixedFetchOption) private var fixedFetchOption
	@Default(.rollingFetchDays) private var rollingFetchDays
	private let intervalService = IntervalService()
	
	func getIntervalText() -> String {
		var isos: (from: String, to: String) = (from: "", to: "")
		
		if (useRollingCount) {
			isos = intervalService.getISOsForRolling(rollingDays: Int(rollingFetchDays))
		} else {
			if (fixedFetchOption == FixedFetchOptions.day.rawValue) {
				return "today"
			}
			
			isos = intervalService.getISOsForFixedIntervals(fixedFetchOption: fixedFetchOption)
		}
		
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/yy"
		
		let fromFormatted = isoFormatter.date(from: isos.from)
			.map { dateFormatter.string(from: $0) } ?? ""
		
		let toFormatted = isoFormatter.date(from: isos.to)
			.map { dateFormatter.string(from: $0) } ?? ""
		
		return "from \(fromFormatted) to \(toFormatted)"
	}
	
	var count: Int {
		return commitFetcherService.commitFetcher.commitCount
	}

	var body: some View {
		VStack {
			VStack(alignment: .leading) {
				Text("\(count) \(count == 1 ? "Contribution" : "Contributions")").font(.headline)
				Text(getIntervalText())
			}
		}
		.padding()
	}
}

