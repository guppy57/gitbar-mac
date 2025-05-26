# GitBar for Macintosh
A while back, I ran into an app called CommitBar that showed a few cells of my GitHub contribution graph in the Mac menu bar. As much as I liked the concept, I realized that just viewing the green squircles doesn't really help provide context. Thus, I decided to build something that literally just fetches and displays the total contribution count for GitHub.

## Installation

## Setup
Once you download the app, open up the settings by clicking on the Menu Bar item and then you add your GitHub username and your GitHub Classic Token.

**Please Note: You have to use a GitHub Classic Tokoen and NOT the new Personal Access Tokens (PAT).** I'm not sure exactly why this is the case, but just that when using PATs, I wasn't able to get the sort of data needed from GitHub's GraphQL API.

## Customization
Right now, you can adjust the following settings:
1. Fetch Interval - this is how many seconds you want GitBar to wait for between fetching your total contributions from GitHub
2. Number of Days in the past to fetch - you can adjust the number of days you want GitBar to get your contribution count for. The maximum is 365 days and the minium is 1 day.
3. Icon - ...

## Have any issues?

## Credits
Special Thanks:
    GitHub API Team
    SwiftUI Community

Third-Party Libraries:
  [Defaults - Sindre Sorhus](https://github.com/sindresorhus/Defaults)
	[Luminare - Kai](https://github.com/MrKai77/Luminare)

Icons:
    SF Symbols by Apple
