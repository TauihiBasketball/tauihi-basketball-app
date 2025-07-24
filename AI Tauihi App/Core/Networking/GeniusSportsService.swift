import Foundation

class GeniusSportsService: SportsDataService {
    private let baseURL = "https://api.geniussports.com/v1"
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private var headers: [String: String] {
        [
            "x-api-key": apiKey,
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    func fetchLeagues() async throws -> [League] {
        let url = URL(string: "\(baseURL)/leagues")!
        return try await performRequest(url: url)
    }
    
    func fetchLeague(by id: Int) async throws -> League {
        let url = URL(string: "\(baseURL)/leagues/\(id)")!
        return try await performRequest(url: url)
    }
    
    // MARK: - SportsDataService Protocol Implementation
    func fetchTeams(leagueId: Int) async throws -> [Team] {
        let url = URL(string: "\(baseURL)/leagues/\(leagueId)/teams")!
        return try await performRequest(url: url)
    }
    
    func fetchGames(competitionId: Int) async throws -> [Match] {
        let url = URL(string: "\(baseURL)/competitions/\(competitionId)/matches")!
        return try await performRequest(url: url)
    }
    
    func fetchLiveGames(competitionId: Int) async throws -> [Match] {
        let url = URL(string: "\(baseURL)/competitions/\(competitionId)/matches/live")!
        return try await performRequest(url: url)
    }
    
    func fetchStandings(competitionId: Int) async throws -> [Standing] {
        let url = URL(string: "\(baseURL)/competitions/\(competitionId)/standings")!
        return try await performRequest(url: url)
    }
    
    func fetchPlayers(teamId: Int) async throws -> [Player] {
        let url = URL(string: "\(baseURL)/teams/\(teamId)/players")!
        return try await performRequest(url: url)
    }
    
    func fetchTeamStatistics(teamId: Int, competitionId: Int) async throws -> [TeamStatistic] {
        let url = URL(string: "\(baseURL)/teams/\(teamId)/statistics?competitionId=\(competitionId)")!
        return try await performRequest(url: url)
    }
    
    func fetchPlayerStatistics(playerId: Int, competitionId: Int) async throws -> [PersonStatistic] {
        let url = URL(string: "\(baseURL)/persons/\(playerId)/statistics?competitionId=\(competitionId)")!
        return try await performRequest(url: url)
    }
    
    // MARK: - Legacy Methods (for backward compatibility)
    func fetchTeam(by id: Int) async throws -> Team {
        let url = URL(string: "\(baseURL)/teams/\(id)")!
        return try await performRequest(url: url)
    }
    
    func fetchMatch(by id: Int) async throws -> Match {
        let url = URL(string: "\(baseURL)/matches/\(id)")!
        return try await performRequest(url: url)
    }
    
    private func performRequest<T: Codable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeniusSportsError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GeniusSportsError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(GeniusSportsResponse<T>.self, from: data)
            return result.data
        } catch {
            throw GeniusSportsError.decodingError(error)
        }
    }
}

// MARK: - Response Models
struct GeniusSportsResponse<T: Codable>: Codable {
    let data: T
    let meta: Meta
}

struct Meta: Codable {
    let pagination: Pagination?
}

struct Pagination: Codable {
    let page: Int
    let perPage: Int
    let total: Int
    let totalPages: Int
}

struct League: Codable, Identifiable {
    let id: Int
    let name: String
    let externalId: String?
    let sport: String?
    let country: String?
    let logo: String?
}

struct Match: Codable, Identifiable {
    let id: Int
    let competitionId: Int
    let externalId: String?
    let scheduledTime: String
    let startTime: String?
    let endTime: String?
    let status: String
    let venueId: Int?
    let homeTeamId: Int?
    let awayTeamId: Int?
    let homeScore: Int?
    let awayScore: Int?
    let periods: [Period]?
}

struct Period: Codable {
    let periodNumber: Int
    let homeScore: Int?
    let awayScore: Int?
    let status: String
}

struct TeamStatistic: Codable {
    let teamId: Int
    let matchId: Int
    let periodNumber: Int
    let points: Int?
    let fieldGoalsMade: Int?
    let fieldGoalsAttempted: Int?
    let threePointersMade: Int?
    let threePointersAttempted: Int?
    let freeThrowsMade: Int?
    let freeThrowsAttempted: Int?
    let rebounds: Int?
    let offensiveRebounds: Int?
    let defensiveRebounds: Int?
    let assists: Int?
    let steals: Int?
    let blocks: Int?
    let turnovers: Int?
    let fouls: Int?
}

struct PersonStatistic: Codable {
    let personId: Int
    let matchId: Int
    let teamId: Int
    let periodNumber: Int
    let points: Int?
    let fieldGoalsMade: Int?
    let fieldGoalsAttempted: Int?
    let threePointersMade: Int?
    let threePointersAttempted: Int?
    let freeThrowsMade: Int?
    let freeThrowsAttempted: Int?
    let rebounds: Int?
    let offensiveRebounds: Int?
    let defensiveRebounds: Int?
    let assists: Int?
    let steals: Int?
    let blocks: Int?
    let turnovers: Int?
    let fouls: Int?
    let minutesPlayed: Int?
}

// MARK: - Error Types
enum GeniusSportsError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case apiError(message: String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .apiError(let message):
            return "API error: \(message)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
} 