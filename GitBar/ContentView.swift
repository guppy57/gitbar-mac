//
//  ContentView.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/6/25.
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var model: CommitInfoModel

	var body: some View {
		VStack {
			Text("Shared Property: \(model.commitCount)")
			Button("Update Property") {
				model.commitCount = model.commitCount + 2
			}
			
		}
		.padding()
	}
}

