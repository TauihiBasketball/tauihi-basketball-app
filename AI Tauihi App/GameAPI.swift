import Foundation

struct GameAPI: Identifiable, Codable {
    var id: String { matchId }
    var date: String
    var time: String
    var home: String
    var away: String
    var venue: String
    var matchId: String
    var url: String
    var homeLogo: String?
    var awayLogo: String?
    var homeScore: String?
    var awayScore: String?
    var status: String?
} 