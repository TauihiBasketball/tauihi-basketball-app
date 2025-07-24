import Foundation

struct Team: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let logoURL: URL
    let coach: String
    let website: URL
    let roster: [Player]

    static let sampleTeams: [Team] = [
        Team(
            id: UUID(),
            name: "Northern Kāhu",
            logoURL: URL(string: "https://tauihi.basketball/wp-content/uploads/2022/05/Kahu-Logo.png")!,
            coach: "Coach Smith",
            website: URL(string: "https://tauihi.basketball/teams/northern-kahu/")!,
            roster: Player.samplePlayers
        ),
        Team(
            id: UUID(),
            name: "Tokomanawa Queens",
            logoURL: URL(string: "https://tauihi.basketball/wp-content/uploads/2022/05/Queens-Logo.png")!,
            coach: "Coach Jones",
            website: URL(string: "https://tauihi.basketball/teams/tokomanawa-queens/")!,
            roster: Player.samplePlayers
        )
    ]
} 