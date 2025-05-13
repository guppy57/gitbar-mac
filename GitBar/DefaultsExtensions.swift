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
	static let fetchInterval = Key<Double>("fetchInterval", default: 5.0, iCloud: true)
	static let githubToken = Key<String>("githubToken", default: "", iCloud: false)
	static let rollingFetchDays = Key<Double>("rollingFetchDays", default: 1.0, iCloud: true)
}
