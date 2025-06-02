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
	
	func fetchCommits() throws -> Int {
		self.isLoading = true
		let IS = IntervalService()
		let isos = useRollingCount ? IS.getISOsForRolling(rollingDays: Int(rollingFetchDays)) : IS.getISOsForFixedIntervals(fixedFetchOption: fixedFetchOption)
		
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

