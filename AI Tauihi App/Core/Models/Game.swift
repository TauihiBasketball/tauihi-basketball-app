import Foundation

struct Game: Identifiable, Equatable, Codable {
    let id: UUID
    let homeTeam: Team
    let awayTeam: Team
    let scheduledTime: String // ISO8601 date string from API
    let venue: String
    let homeScore: Int?
    let awayScore: Int?
    let status: String // e.g. "upcoming", "final", "inprogress"
    
    // Computed property for Date
    var date: Date {
        ISO8601DateFormatter().date(from: scheduledTime) ?? Date()
    }
    
    // Computed property for formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    // Computed property for formatted time
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Computed property to check if game is live
    var isLive: Bool {
        return status.lowercased() == "inprogress"
    }
    
    // Computed property to check if game is upcoming
    var isUpcoming: Bool {
        return date > Date() && !isLive
    }

    static let sampleGames: [Game] = [
        Game(
            id: UUID(),
            homeTeam: Team.sampleTeams[0],
            awayTeam: Team.sampleTeams[1],
            scheduledTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600 * 24)),
            venue: "Tauihi Arena",
            homeScore: nil,
            awayScore: nil,
            status: "upcoming"
        ),
        Game(
            id: UUID(),
            homeTeam: Team.sampleTeams[1],
            awayTeam: Team.sampleTeams[0],
            scheduledTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600 * 48)),
            venue: "Queens Court",
            homeScore: 78,
            awayScore: 82,
            status: "final"
        )
    ]
} 