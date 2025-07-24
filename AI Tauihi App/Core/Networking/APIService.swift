import Foundation

protocol APIServiceProtocol {
    func fetchTeams() async throws -> [Team]
    func fetchGames() async throws -> [Game]
    func fetchPlayers() async throws -> [Player]
    func fetchArticles() async throws -> [Article]
}

final class APIService: APIServiceProtocol {
    func fetchTeams() async throws -> [Team] {
        // TODO: Implement real networking
        return []
    }
    func fetchGames() async throws -> [Game] {
        // TODO: Implement real networking
        return []
    }
    func fetchPlayers() async throws -> [Player] {
        // TODO: Implement real networking
        return []
    }
    func fetchArticles() async throws -> [Article] {
        // TODO: Implement real networking
        return []
    }
}

// MARK: - Mock API Service for Development

final class MockAPIService: APIServiceProtocol {
    func fetchTeams() async throws -> [Team] {
        return [
            Team(id: UUID(), name: "Whai", logoURL: URL(string: "https://example.com/whai.png")!, coach: "Coach Smith", website: URL(string: "https://tauihi.basketball/teams/whai")!, roster: Player.samplePlayers),
            Team(id: UUID(), name: "Tokomanawa", logoURL: URL(string: "https://example.com/tokomanawa.png")!, coach: "Coach Jones", website: URL(string: "https://tauihi.basketball/teams/tokomanawa")!, roster: Player.samplePlayers),
            Team(id: UUID(), name: "Northern Kāhu", logoURL: URL(string: "https://example.com/kahu.png")!, coach: "Coach Lee", website: URL(string: "https://tauihi.basketball/teams/kahu")!, roster: Player.samplePlayers),
            Team(id: UUID(), name: "Pouākai", logoURL: URL(string: "https://example.com/pouakai.png")!, coach: "Coach Brown", website: URL(string: "https://tauihi.basketball/teams/pouakai")!, roster: Player.samplePlayers)
        ]
    }
    func fetchGames() async throws -> [Game] {
        let teams = try await fetchTeams()
        return [
            Game(id: UUID(), homeTeam: teams[0], awayTeam: teams[1], scheduledTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)), venue: "Eventfinda Stadium", homeScore: 0, awayScore: 0, status: "upcoming"),
            Game(id: UUID(), homeTeam: teams[2], awayTeam: teams[3], scheduledTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(7200)), venue: "Pulman Arena", homeScore: 0, awayScore: 0, status: "upcoming"),
            Game(id: UUID(), homeTeam: teams[0], awayTeam: teams[2], scheduledTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-600)), venue: "Eventfinda Stadium", homeScore: 68, awayScore: 65, status: "live"),
            Game(id: UUID(), homeTeam: teams[1], awayTeam: teams[3], scheduledTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)), venue: "Pulman Arena", homeScore: 80, awayScore: 75, status: "finished")
        ]
    }
    func fetchPlayers() async throws -> [Player] {
        return []
    }
    func fetchArticles() async throws -> [Article] {
        return [
            Article(id: UUID(), headline: "Tauihi Basketball: Big Win for Whai!", thumbnailURL: URL(string: "https://example.com/news1.png")!, publishedAt: Date().addingTimeInterval(-3600), url: URL(string: "https://example.com/news/1")!),
            Article(id: UUID(), headline: "Northern Kāhu edge out Pouākai in thriller", thumbnailURL: URL(string: "https://example.com/news2.png")!, publishedAt: Date().addingTimeInterval(-7200), url: URL(string: "https://example.com/news/2")!),
            Article(id: UUID(), headline: "Tokomanawa on the rise in Tauihi standings", thumbnailURL: URL(string: "https://example.com/news3.png")!, publishedAt: Date().addingTimeInterval(-10800), url: URL(string: "https://example.com/news/3")!)
        ]
    }
} 