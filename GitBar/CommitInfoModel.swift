//
//  CommitInfoModel.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/6/25.
//

import Foundation
import SwiftUI
import Combine

class CommitInfoModel: ObservableObject {
	@Published var commitCount: Int {
		didSet {
			UserDefaults.standard.set(commitCount, forKey: "commitCount")
		}
	}
	
	init() {
		// Load the saved value, or use a default if not available
		self.commitCount = UserDefaults.standard.integer(forKey: "commitCount")
	}
}
