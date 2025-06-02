//
//  IntervalService.swift
//  GitBar
//
//  Created by Armaan Gupta on 6/1/25.
//
import Foundation

class IntervalService {
	func getISOsForRolling(rollingDays: Int) -> (from: String, to: String) {
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

		let fromDate: Date = {
			return Calendar.current.date(byAdding: .day, value: -1 * Int(rollingDays), to: Date()) ?? Date()
		}()
		
		var fromISO = isoFormatter.string(from: fromDate)
		var toISO = isoFormatter.string(from: Date())
		
		return (from: fromISO, to: toISO)
	}
	
	func getISOsForFixedIntervals(fixedFetchOption: String) -> (from: String, to: String) {
		var fromISO = ""
		var toISO = ""
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		var calendar = Calendar.current
		let now = Date()
		
		if (fixedFetchOption == FixedFetchOptions.day.rawValue) {
			let startOfDay = calendar.startOfDay(for: now)
			
			var components = DateComponents()
			components.day = 1
			components.second = -1
			
			let endOfDay = calendar.date(byAdding: components, to: startOfDay)!
			
			fromISO = isoFormatter.string(from: startOfDay)
			toISO = isoFormatter.string(from: endOfDay)
		} else if (fixedFetchOption == FixedFetchOptions.week.rawValue) {
			calendar.firstWeekday = 2
			let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)!.start
			
			var components = DateComponents()
			components.day = 7
			components.second = -1
			let endOfWeek = calendar.date(byAdding: components, to: startOfWeek)!
			
			fromISO = isoFormatter.string(from: startOfWeek)
			toISO = isoFormatter.string(from: endOfWeek)
		} else if (fixedFetchOption == FixedFetchOptions.month.rawValue) {
			let startOfMonth = calendar.dateInterval(of: .month, for: now)!.start
			let endOfMonth = calendar.dateInterval(of: .month, for: now)!.end.addingTimeInterval(-1)
			
			fromISO = isoFormatter.string(from: startOfMonth)
			toISO = isoFormatter.string(from: endOfMonth)
		} else if (fixedFetchOption == FixedFetchOptions.quarter.rawValue) {
			let month = calendar.component(.month, from: now)
			let quarterStartMonth: Int
			
			switch month {
			case 1...3:
				quarterStartMonth = 1  // Q1: Jan-Mar
			case 4...6:
				quarterStartMonth = 4  // Q2: Apr-Jun
			case 7...9:
				quarterStartMonth = 7  // Q3: Jul-Sep
			default:
				quarterStartMonth = 10 // Q4: Oct-Dec
			}
			
			var components = calendar.dateComponents([.year], from: now)
			components.month = quarterStartMonth
			components.day = 1
			
			let startOfQuarter = calendar.date(from: components)!
			var endComponents = DateComponents()
			endComponents.month = 3
			endComponents.second = -1
			let endOfQuarter = calendar.date(byAdding: endComponents, to: startOfQuarter)!
			
			fromISO = isoFormatter.string(from: startOfQuarter)
			toISO = isoFormatter.string(from: endOfQuarter)
		} else if (fixedFetchOption == FixedFetchOptions.year.rawValue) {
			let startOfYear = calendar.dateInterval(of: .year, for: now)!.start
			let endOfYear = calendar.dateInterval(of: .year, for: now)!.end.addingTimeInterval(-1)
			
			fromISO = isoFormatter.string(from: startOfYear)
			toISO = isoFormatter.string(from: endOfYear)
		} else {
			// something went wrong!
		}

		return (from: fromISO, to: toISO)
	}
}
