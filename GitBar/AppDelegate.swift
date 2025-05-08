//
//  AppDelegate.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/7/25.
//

import Defaults
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
		SettingsManager.fullyClose()
		return false
	}
	
	func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
		SettingsManager.open()
		return true
	}
}
