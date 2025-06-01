//
//  CommitFetcher.swift
//  GitBar
//
//  Created by Armaan Gupta on 5/6/25.
//

import Foundation
import Defaults

struct GraphQLPayload: Codable {
	var query: String
}

struct GitHubResponse: Codable {
	let data: GitHubData
}

struct GitHubData: Codable {
	let user: GitHubUser
}

struct GitHubUser: Codable {
	let contributionsCollection: ContributionsCollection
}

struct ContributionsCollection: Codable {
	let contributionCalendar: ContributionCalendar
}

struct ContributionCalendar: Codable {
	let totalContributions: Int
}

class CommitFetcher: ObservableObject {
	@Published var commitCount: Int
	@Published var isLoading: Bool = false
	
	init() {
		self.commitCount = Defaults[.lastCommitCount]
	}
	
	private func parseGitHubRespose(jsonString: String) -> Int? {
		guard let jsonData = jsonString.data(using: .utf8) else {
			print("Failed to convert string to data")
			return nil
		}
		
		do {
			let decoder = JSONDecoder()
			let response = try decoder.decode(GitHubResponse.self, from: jsonData)
			return response.data.user.contributionsCollection.contributionCalendar.totalContributions
		} catch {
			print("Error decoding JSON: \(error)")
			return nil
		}
	}
	
	enum FetchCommitsError: Error {
		case invalidUrl
		case networkError
		case responseFailed
		case encodingError
	}
	
	var githubToken: String {
		Defaults[.githubToken]
	}
	
	var githubUsername: String {
		Defaults[.githubUsername]
	}
	
	var rollingFetchDays: Double {
		Defaults[.rollingFetchDays]
	}
	
	var useRollingCount: Bool {
		Defaults[.useRollingCount]
	}
	
	var fixedFetchOption: String {
		Defaults[.fixedFetchOption]
	}
	
	
	func getISOs() -> (from: String, to: String) {
		var fromISO = ""
		var toISO = ""
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		var calendar = Calendar.current
		let now = Date()

		if (useRollingCount) {
			let fromDate: Date = {
				return calendar.date(byAdding: .day, value: -1 * Int(rollingFetchDays), to: Date()) ?? Date()
			}()
			fromISO = isoFormatter.string(from: fromDate)
			toISO = isoFormatter.string(from: now)
		} else {
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
		}

		return (from: fromISO, to: toISO)
	}
	
	func fetchCommits() throws -> Int {
		self.isLoading = true
		let isos = getISOs()
		
		guard let url = URL(string: "https://api.github.com/graphql") else {
			print("api.github.com/graphql is invalid for some reason")
			self.isLoading = false
			throw FetchCommitsError.invalidUrl
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("bearer \(githubToken)", forHTTPHeaderField: "Authorization")

		let queryWithParams = """
			query {
				user(login: "\(githubUsername)") {
				contributionsCollection(from: "\(isos.from)", to: "\(isos.to)") {
				  contributionCalendar {
				    totalContributions
				  }
				}
			  }
			}
		"""
		
		do {
			let body = GraphQLPayload(query: queryWithParams)
			let jsonData = try JSONEncoder().encode(body)
			request.httpBody = jsonData
			
			URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
				guard let self = self else { return }
				
				DispatchQueue.main.async {
					if let error = error {
						print("Network error: \(error.localizedDescription)")
						self.isLoading = false
						return
					}
					
					guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
						print("Failed with status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
						self.isLoading = false
						return
					}
					
					if let data = data {
						if let responseString = String(data: data, encoding: .utf8) {
							print(responseString)
							let parsedTotalCommits = self.parseGitHubRespose(jsonString: responseString)
							
							if (parsedTotalCommits == nil) {
								print("Parsing failed")
							} else {
								self.commitCount = parsedTotalCommits ?? 0
							}
						}
					}
					
					
				}
			}.resume()
		} catch {
			print("Error encoding request: \(error)")
			self.isLoading = false
			throw FetchCommitsError.encodingError
		}
		
		return self.commitCount
	}
}

