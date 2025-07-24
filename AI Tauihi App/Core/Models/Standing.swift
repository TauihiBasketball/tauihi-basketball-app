import Foundation

struct Standing: Identifiable, Equatable, Codable {
    let id: UUID
    let rank: Int
    let team: Team
    let wins: Int
    let losses: Int
    let percent: Double
    
    // API response fields
    let position: Int
    let won: Int
    let lost: Int
    let percentage: Double
    let teamName: String
    let teamId: Int
    let images: TeamImages?
    
    enum CodingKeys: String, CodingKey {
        case position, won, lost, percentage, teamName, teamId, images
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        position = try container.decode(Int.self, forKey: .position)
        won = try container.decode(Int.self, forKey: .won)
        lost = try container.decode(Int.self, forKey: .lost)
        percentage = try container.decode(Double.self, forKey: .percentage)
        teamName = try container.decode(String.self, forKey: .teamName)
        teamId = try container.decode(Int.self, forKey: .teamId)
        images = try container.decodeIfPresent(TeamImages.self, forKey: .images)
        
        // Create Team object from API data
        let logoURL = URL(string: images?.logo?.S1?.url ?? "")
        team = Team(
            id: UUID(),
            name: teamName,
            logoURL: logoURL ?? URL(string: "https://example.com/default.png")!,
            coach: "",
            website: URL(string: "https://tauihi.basketball")!,
            roster: []
        )
        
        // Set computed properties
        id = UUID()
        rank = position
        wins = won
        losses = lost
        percent = percentage
    }
    
    init(rank: Int, team: Team, wins: Int, losses: Int, percent: Double) {
        self.id = UUID()
        self.rank = rank
        self.team = team
        self.wins = wins
        self.losses = losses
        self.percent = percent
        
        // API fields
        self.position = rank
        self.won = wins
        self.lost = losses
        self.percentage = percent
        self.teamName = team.name
        self.teamId = 0
        self.images = nil
    }

    static let sampleStandings: [Standing] = [
        Standing(rank: 1, team: Team.sampleTeams[0], wins: 8, losses: 2, percent: 0.800),
        Standing(rank: 2, team: Team.sampleTeams[1], wins: 7, losses: 3, percent: 0.700)
    ]
}

struct TeamImages: Codable {
    let logo: TeamLogo?
}

struct TeamLogo: Codable {
    let S1: LogoSize?
    let T1: LogoSize?
}

struct LogoSize: Codable {
    let url: String
} 