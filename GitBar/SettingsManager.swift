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
import LaunchAtLogin

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
	case appearenceTab
	case aboutTab
	
	var title: String {
		switch self {
		case .settingsTab: .init(localized: "Settings tab: Settings", defaultValue: "Settings")
		case .appearenceTab: .init(localized: "Settings Tab: Appearence", defaultValue: "Appearence")
		case .aboutTab: .init(localized: "Settings tab: About", defaultValue: "About")
		}
	}
	
	var icon: Image {
		switch self {
		case .settingsTab: Image(systemName: "gearshape")
		case .appearenceTab: Image(systemName: "paintpalette")
		case .aboutTab: Image(systemName: "info.circle")
		}
	}
	
	@ViewBuilder func view() -> some View {
		switch self {
		case .settingsTab: SettingsTabView()
		case .appearenceTab: AppearenceTabView()
		case .aboutTab: AboutTabView()
		}
	}
}

public enum CustomIcon: String, CaseIterable {
	var id: String { fileName }
	
	case github = "github"
	case githubSquare = "githubSquare"
	case githubAlt = "githubAlt"
	case git = "git"
	case codeBranch = "codeBranch"
	case codeCommit = "codeCommit"
	
	var fileName: String {
		switch self {
		case .github: "github-18px"
		case .githubSquare: "github-square-18px"
		case .githubAlt: "github-alt-18px"
		case .git: "git-18px"
		case .codeBranch: "code-branch-18px"
		case .codeCommit: "code-commit-18px"
		}
	}
	
	var fileNameWhite: String {
		switch self {
		case .github: "github-18px-w"
		case .githubSquare: "github-square-18px-w"
		case .githubAlt: "github-alt-18px-w"
		case .git: "git-18px-w"
		case .codeBranch: "code-branch-18px-w"
		case .codeCommit: "code-commit-18px-w"
		}
	}
	
	var displayName: String {
		switch self {
		case .github: "GitHub Octocat"
		case .githubSquare: "GitHub Octocat Square"
		case .githubAlt: "GitHub Octocat Alt"
		case .git: "Git"
		case .codeBranch: "Code Branch"
		case .codeCommit: "Code Commit"
		}
	}
}

public enum FixedFetchOptions: String, CaseIterable {
	case day = "today"
	case week = "this_week"
	case month = "this_month"
	case quarter = "this_quarter"
	case year = "this_year"
	
	var displayName: String {
		switch self {
		case .day: "Today"
		case .week: "this Week"
		case .month: "this Month"
		case .quarter: "this Quarter"
		case .year: "this Year"
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
				LuminareSidebarSection("GitBar for Mac", selection: $model.currentTab, items: [Tab.settingsTab, Tab.appearenceTab, Tab.aboutTab])
			}
			.frame(width: 220)
			
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
			.frame(width: 420)
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
	@Default(.fixedFetchOption) private var fixedFetchOption
	@Default(.useRollingCount) private var useRollingCount
	
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
			
			Menu {
				ForEach(FixedFetchOptions.allCases, id: \.self) { interval in
					Button(action: { fixedFetchOption = interval.rawValue }) {
						Text(interval.displayName)
					}
				}
			} label: {
				HStack {
					if let currentFetchOption = FixedFetchOptions(rawValue: fixedFetchOption) {
						Text("Fetch contributions for \(currentFetchOption.displayName)")
					} else {
						Text("Fetch contributions for \(FixedFetchOptions.week.displayName)")
					}
					Spacer()
				}
				.frame(maxWidth: .infinity)
				.cornerRadius(6)
				.padding(.bottom, 4)
			}
			.menuStyle(.borderlessButton)
			.padding(6)
			
			LuminareToggle("Use rolling days instead of a fixed interval?", isOn: Binding(
				get: { useRollingCount },
				set: {
					newValue in
					useRollingCount = newValue
				}
			))
			
			LuminareValueAdjuster(
				"Number of rolling days in the past to fetch",
				value: $rollingFetchDays,
				sliderRange: 0...365,
				suffix: "days",
				lowerClamp: true,
				upperClamp: true,
			)
			.disabled(!useRollingCount)
		}
		
		LuminareSection {
			LuminareToggle("Launch at login", isOn: Binding(
				get: { LaunchAtLogin.isEnabled },
				set: { newValue in
					LaunchAtLogin.isEnabled = newValue
				}
			))
		}
	}
}

struct AppearenceTabView: View {
	@Environment(\.colorScheme) var colorScheme
	@Default(.showIcon) private var showIcon
	@Default(.customIconString) private var customIconString
	
	var body: some View {
		LuminareSection("Icon") {
			Menu {
				ForEach(CustomIcon.allCases, id: \.self) { icon in
					Button(action: { customIconString = icon.rawValue }) {
						Label {
							Text(icon.displayName)
						} icon: {
							Image(colorScheme == .dark ? icon.fileNameWhite : icon.fileName)
						}
					}
				}
			} label: {
				HStack {
					if let currentIcon = CustomIcon(rawValue: customIconString) {
						Image(colorScheme == .dark ? currentIcon.fileNameWhite : currentIcon.fileName)
						Text("  \(currentIcon.displayName)")
					} else {
						Image(colorScheme == .dark ? CustomIcon.github.fileNameWhite : CustomIcon.github.fileName)
						Text("  \(CustomIcon.github.displayName)")
					}
					Spacer()
					Image(systemName: "chevron.up.chevron.down")
				}
				.frame(maxWidth: .infinity)
				.cornerRadius(6)
				.padding(.bottom, 4)
			}
			.menuStyle(.borderlessButton)
			.padding(8)
			
			LuminareToggle("Show icon in menu bar", isOn: $showIcon)
		}
	}
}

struct AboutTabView: View {
	@Environment(\.openURL) var openURL
	@State private var hover: Bool = false
	
	var body: some View {
		LuminareSection {
			Text(
				"Checkout the GitBar website for new updates and if you have any feedback or find any bugs with GitBar, please let us know on GitHub. Your feedback is absolutely vital!"
			)
			.padding(8)

			HStack(spacing: 2) {
				Button("Visit Website") {
					openURL(URL(string: "https://gitbar.guppy57.com")!)
				}
				
				Button("Send Feedback") {
					openURL(URL(string: "https://github.com/guppy57/gitbar-mac")!)
				}
			}
		}
		
		LuminareSection("Credits") {
			Text("""
			Developer:
				Armaan Gupta - https://guppy57.com

			Special Thanks:
				GitHub API Team
				SwiftUI Community

			Third-Party Libraries:
				[Defaults - Sindre Sorhus](https://github.com/sindresorhus/Defaults)
				[LaunchAtLogin-Modern - Sindre Sorhus](https://github.com/sindresorhus/LaunchAtLogin-Modern)
				[Luminare - Kai](https://github.com/MrKai77/Luminare)

			Icons:
				SF Symbols by Apple
				FontAwesome
			""")
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(8)
				.onHover { isHovered in
					self.hover = isHovered
					DispatchQueue.main.async {
						if (self.hover) {
							NSCursor.pointingHand.push()
						} else {
							NSCursor.pop()
						}
					}
				}
		}
	}
}
