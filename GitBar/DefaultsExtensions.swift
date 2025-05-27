//
//  DefaultsExtensions.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/7/25.
//

import Defaults
import SwiftUI

extension Defaults.Keys {
	static let githubUsername = Key<String>("githubUsername", default: "guppy57", iCloud: true)
	static let fetchInterval = Key<Int>("fetchInterval", default: 5, iCloud: true)
	static let githubToken = Key<String>("githubToken", default: "", iCloud: false)
	static let rollingFetchDays = Key<Double>("rollingFetchDays", default: 1.0, iCloud: true)
	static let lastCommitCount = Key<Int>("lastCommitCount", default: 0, iCloud: true)
	static let showIcon = Key<Bool>("showIcon", default: false, iCloud: true)
	static let customIconString = Key<String>("customIconString", default: "github", iCloud: true)
}
