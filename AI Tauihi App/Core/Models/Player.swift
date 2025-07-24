import Foundation

struct Player: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let position: String
    let number: Int

    static let samplePlayers: [Player] = [
        Player(id: UUID(), name: "Jane Doe", position: "G", number: 5),
        Player(id: UUID(), name: "Sarah Smith", position: "F", number: 12),
        Player(id: UUID(), name: "Emily Brown", position: "C", number: 23)
    ]
} 