//
//  GitBarApp.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/6/25.
//

import SwiftUI
import Defaults

@main
struct GitBarApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject private var commitFetcherService = CommitFetcherService()
	
	var body: some Scene {
		MenuBarExtra {
			VStack {
				ContentView()
					.environmentObject(commitFetcherService)
				
				Divider()
				
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
	@Default(.showIcon) private var showIcon
	@Default(.customIconString) private var customIconString
	var commitCount: Int
	
	private var icon: CustomIcon {
		CustomIcon(rawValue: customIconString) ?? .github
	}
	
	var body: some View {
		HStack {
			Text(" \(commitCount)")
				.monospacedDigit()
			if (showIcon) {
				Image(icon.fileNameWhite)
					.resizable()
					.renderingMode(.template)
			}
		}
	}
}
