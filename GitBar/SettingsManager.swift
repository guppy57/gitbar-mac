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
		NSApp.setActivationPolicy(.regular)
	}
	
	static func fullyClose() {
		luminare?.close()
		luminare = nil
		NSApp.setActivationPolicy(.accessory)
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

enum FetchIntervalConfiguration: Int, Defaults.Serializable, CaseIterable, Identifiable {
	var id: Self { self }
	
	case reallyFast = 2
	case fast = 6
	case balanced = 15
	case slow = 30
	case reallySlow = 60
	
	var name: LocalizedStringKey {
		switch self {
		case .reallyFast:
			"Really fast"
		case .fast:
			"Fast"
		case .balanced:
			"Balanced"
		case .slow:
			"Slow"
		case .reallySlow:
			"Really slow"
		}
	}
}

struct SettingsTabView: View {
	@Default(.githubUsername) private var githubUsername
	@Default(.githubToken) private var githubToken
	@Default(.fetchInterval) private var fetchInterval
	@Default(.rollingFetchDays) private var rollingFetchDays
	
	private let fetchIntervalOptions = [2, 5, 15, 30, 60, 120]
	
	var body: some View {
		LuminareSection("GitHub details") {
			LuminareTextField("GitHub Username", text: Binding(get: { githubUsername }, set: { githubUsername = $0}))
			LuminareTextField("GitHub Token", text: Binding(get: { githubToken }, set: { githubToken = $0}))
		}
		
		LuminareSection("Fetch settings") {
			LuminareSliderPicker(
				"Fetch Interval",
				fetchIntervalOptions,
				selection: Binding(
					get: {
						fetchIntervalOptions.min(by: { abs($0 - fetchInterval) < abs($1 - fetchInterval) }) ?? fetchInterval
					},
					set: { fetchInterval = $0 }
				),
				label: { value in
					LocalizedStringKey("\(value) sec")
				}
			)

			
			LuminareValueAdjuster(
				"Number of days in the past to fetch",
				value: $rollingFetchDays,
				sliderRange: 0...365,
				suffix: "days",
				lowerClamp: true,
				upperClamp: true
			)
		}
	}
}

struct AboutTabView: View {
	var body: some View {
		Text("About")
	}
}
