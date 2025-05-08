//
//  GitBarApp.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/6/25.
//

import SwiftUI

@main
struct GitBarApp: App {
	@StateObject private var model = CommitInfoModel()
	
	var body: some Scene {
		MenuBarExtra {
			VStack {
				ContentView()
					.environmentObject(model)
			
				Button("Open settings") {
					SettingsManager.open()
				}
				
				Button("Quit GitBar") {
					NSApplication.shared.terminate(nil)
				}
			}
			.padding(.vertical, 5)
		} label: {
			HStack {
				Text("\(model.commitCount) commits")
				Label("GitBar", systemImage: "circle")
			}
		}
	}
}
