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
	private var fixedFetchOptionObserver: AnyCancellable?
	
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
		
		fixedFetchOptionObserver = Defaults.publisher(.fixedFetchOption)
			.sink { [weak self] newValue in
				self?.refreshData()
			}
	}
	
	deinit {
		timer?.cancel()
		defaultsObserver?.cancel()
		fixedFetchOptionObserver?.cancel()
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
		
		let commitCount = try? commitFetcher.fetchCommits()
		
		if let commitCount = commitCount {
			Defaults[.lastCommitCount] = commitCount
		}
		
		lastRefreshTime = Date()
	}
}
