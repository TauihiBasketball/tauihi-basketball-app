import Foundation

// MARK: - Backend Service for Production
class BackendService: SportsDataService {
    private let baseURL: String
    private let session: URLSession
    
    init() {
        self.baseURL = APIConfig.Endpoints.backendAPI
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.Limits.timeoutInterval
        config.timeoutIntervalForResource = APIConfig.Limits.timeoutInterval
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic Request Method
    func fetch<T: Codable>(endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw BackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw BackendError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let backendResponse = try decoder.decode(BackendResponse<T>.self, from: data)
            
            if backendResponse.success, let responseData = backendResponse.data {
                return responseData
            } else {
                throw BackendError.apiError(message: backendResponse.error ?? "Unknown error")
            }
        } catch {
            throw BackendError.decodingError(error)
        }
    }
    
    // MARK: - Sports Data Service Protocol Implementation
    func fetchTeams(leagueId: Int) async throws -> [Team] {
        return try await fetch(endpoint: "teams?leagueId=\(leagueId)")
    }
    
    func fetchGames(competitionId: Int) async throws -> [Match] {
        return try await fetch(endpoint: "games?competitionId=\(competitionId)")
    }
    
    func fetchLiveGames(competitionId: Int) async throws -> [Match] {
        return try await fetch(endpoint: "games/live?competitionId=\(competitionId)")
    }
    
    func fetchStandings(competitionId: Int) async throws -> [Standing] {
        return try await fetch(endpoint: "standings?competitionId=\(competitionId)")
    }
    
    func fetchPlayers(teamId: Int) async throws -> [Player] {
        return try await fetch(endpoint: "players?teamId=\(teamId)")
    }
    
    func fetchTeamStatistics(teamId: Int, competitionId: Int) async throws -> [TeamStatistic] {
        return try await fetch(endpoint: "statistics/team?teamId=\(teamId)&competitionId=\(competitionId)")
    }
    
    func fetchPlayerStatistics(playerId: Int, competitionId: Int) async throws -> [PersonStatistic] {
        return try await fetch(endpoint: "statistics/player?playerId=\(playerId)&competitionId=\(competitionId)")
    }
}

// MARK: - Backend Error Types
enum BackendError: Error, LocalizedError {
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