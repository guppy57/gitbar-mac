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

	var body: some View {
		VStack {
			Text("Count: \(commitFetcherService.commitFetcher.commitCount)")
		}
		.padding()
	}
}

