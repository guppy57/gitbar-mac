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
	private var defaultsObserver: AnyCancellable?
	
	init() {
		self.commitFetcher = CommitFetcher()
		self.refreshData()
		
		// Observe changes to fetchInterval default
		defaultsObserver = Defaults.publisher(.fetchInterval)
			.sink { [weak self] newValue in
				// Restart timer with new interval if running
				if self?.isRunning == true {
					self?.stopMonitoring()
					self?.startMonitoring()
				}
			}
	}
	
	func startMonitoring() {
		if isRunning { return }
		
		refreshData()
		
		timer = Timer.publish(every: Double(Defaults[.fetchInterval]), on: .main, in: .common)
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
		print("Refreshing data..... \(Defaults[.fetchInterval]) secs")
		commitFetcher.fetchCommits()
		lastRefreshTime = Date()
	}
}
