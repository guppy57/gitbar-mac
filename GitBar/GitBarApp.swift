//
//  GitBarApp.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/6/25.
//

import SwiftUI

@main
struct GitBarApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject private var commitFetcherService = CommitFetcherService()
	
	var body: some Scene {
		MenuBarExtra {
			VStack {
				ContentView()
					.environmentObject(commitFetcherService)
				
				Button("View project on GitHub") {
					if let url = URL(string: "https://github.com/guppy57/gitbar-mac") {
						NSWorkspace.shared.open(url)
					}
				}
				
				Button("Have an issue? Get support here") {
					if let url = URL(string: "https://gitbar.guppy57.com/support") {
						NSWorkspace.shared.open(url)
					}
				}
				
				Divider()
			
				Button("Open settings") {
					SettingsManager.open()
				}
				.keyboardShortcut(",", modifiers: .command)
				
				Button("Quit GitBar") {
					NSApplication.shared.terminate(nil)
				}
				.keyboardShortcut("q", modifiers: .command)
			}
			.padding(.vertical, 5)
		} label: {
			MenuBarLabel(commitCount: commitFetcherService.commitFetcher.commitCount)
				.environmentObject(commitFetcherService)
				.onAppear() {
					commitFetcherService.startMonitoring()
				}
		}
	}
}

struct MenuBarLabel: View {
	var commitCount: Int
	
	var body: some View {
		HStack(spacing: 4) {
			Text("\(commitCount)")
				.monospacedDigit()
			Image(systemName: "swift")
		}
	}
}
