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
}
