//
//  CommitFetcherService.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/9/25.
//

import SwiftUI
import Defaults
import Combine

class CommitFetcherService: ObservableObject {
	@Published var commitFetcher: CommitFetcher
	@Published var lastRefreshTime = Date()
	
	private var timer: AnyCancellable?
	private var isRunning = false
	
	init() {
		self.commitFetcher = CommitFetcher()
		self.refreshData()
	}
	
	func startMonitoring(interval: TimeInterval = Defaults[.fetchInterval]) {
		if isRunning { return }
		
		refreshData()
		
		timer = Timer.publish(every: interval, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				self?.refreshData()
			}
		
		isRunning = true
	}
	
	func stopMonitoring() {
		timer?.cancel()
		timer = nil
		isRunning = false
	}
	
	private func refreshData() {
		commitFetcher.fetchCommits()
		lastRefreshTime = Date()
	}
}
