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
	let totalCommitContributions: Int
}

class CommitFetcher: ObservableObject {
	@Published var commitCount: Int = 0
	@Published var isLoading: Bool = false
	
	enum CommitFetcherError: Error {
		case networkError
	}
	
	private func parseGitHubRespose(jsonString: String) -> Int? {
		guard let jsonData = jsonString.data(using: .utf8) else {
			print("Failed to convert string to data")
			return nil
		}
		
		do {
			let decoder = JSONDecoder()
			let response = try decoder.decode(GitHubResponse.self, from: jsonData)
			return response.data.user.contributionsCollection.totalCommitContributions
		} catch {
			print("Error decoding JSON: \(error)")
			return nil
		}
	}
	
	func fetchCommits() {
		self.isLoading = true
		
		let yesterday: Date = {
			return Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
		}()
		let fromISO = ISO8601DateFormatter().string(from: yesterday)
		let toISO = ISO8601DateFormatter().string(from: Date())
		
		guard let url = URL(string: "https://api.github.com/graphql") else {
			print("api.github.com/graphql is invalid for some reason")
			self.isLoading = false
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("Bearer \(Defaults[.githubToken])", forHTTPHeaderField: "Authorization")

		let queryWithParams = """
			query {
				user(login: "\(Defaults[.githubUsername])") {
				contributionsCollection(from: "\(fromISO)", to: "\(toISO)") {
				  totalCommitContributions
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
							let parsedTotalCommits = self.parseGitHubRespose(jsonString: responseString)
							
							if (parsedTotalCommits == nil) {
								print("Parsing failed")
							} else {
								self.commitCount = parsedTotalCommits ?? 0
							}
							
						}
					}
					
					self.isLoading = false
				}
			}.resume()
		} catch {
			print("Error encoding request: \(error)")
			self.isLoading = false
		}
	}
}

