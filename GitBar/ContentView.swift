//
//  ContentView.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/6/25.
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var model: CommitInfoModel
	@StateObject var commitFetcher = CommitFetcher()

	var body: some View {
		VStack {
			Text("Count: \(commitFetcher.commitCount)")
			Button("Update Property") {
				commitFetcher.fetchCommits()
			}
		}
		.padding()
		.onAppear() {
			commitFetcher.fetchCommits()
		}
	}
}

