//
//  SettingsManager.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/7/25.
//

import Combine
import Luminare
import SwiftUI
import Defaults

class SettingsManager {
	static var luminare: LuminareWindow?
	
	static func open() {
		if luminare == nil {
			luminare = LuminareWindow(blurRadius: 20) {
				SettingsView()
			}
			luminare?.center()
		}
		
		luminare?.show()
		
		// AppDelegate.isActive = true
		// NSApp.setActivationPolicy(.regular)
	}
	
	static func fullyClose() {
		luminare?.close()
		luminare = nil
		
		// if !Defaults[.showDockIcon] {
		//	 NSApp.setActivationPolicy(.accessory)
		// }
	}
}

extension String: @retroactive Identifiable {
	public var id: String { self }
}

enum Tab: LuminareTabItem, CaseIterable {
	var id: String { title }
	
	case settingsTab
	case aboutTab
	
	var title: String {
		switch self {
		case .settingsTab: .init(localized: "Settings tab: Settings", defaultValue: "Settings")
		case .aboutTab: .init(localized: "Settings tab: About", defaultValue: "About")
		}
	}
	
	var icon: Image {
		switch self {
		case .settingsTab: Image(systemName: "star.fill")
		case .aboutTab: Image(systemName: "star")
		}
	}
	
	@ViewBuilder func view() -> some View {
		switch self {
		case .settingsTab: SettingsTabView()
		case .aboutTab: AboutTabView()
		}
	}
}

class LuminareWindowModel: ObservableObject {
	static let shared = LuminareWindowModel()
	private init() {
		self.currentTab = Tab.settingsTab
	}
	
	@Published var currentTab: Tab
}

struct SettingsView: View {
	@ObservedObject var model = LuminareWindowModel.shared
	
	var body: some View {
		LuminareDividedStack {
			LuminareSidebar {
				LuminareSidebarSection("GitBar for Macintosh", selection: $model.currentTab, items: [Tab.settingsTab, Tab.aboutTab])
			}
			.frame(width: 240)
			
			LuminarePane {
				HStack {
					model.currentTab.iconView()
					Text(model.currentTab.title)
						.font(.title2)
					Spacer()
				}
			} content: {
				model.currentTab.view()
					.transition(.opacity.animation(.easeInOut(duration: 0.15)))
			}
			.frame(width: 400)
		}
	}
}

struct SettingsTabView: View {
	@Default(.githubUsername) private var githubUsername
	
	var body: some View {
		LuminareSection("GitHub username") {
			LuminareTextField("GitHub Username", text: Binding(get: { githubUsername }, set: { githubUsername = $0}))
		}
	}
}

struct AboutTabView: View {
	var body: some View {
		Text("About")
	}
}
