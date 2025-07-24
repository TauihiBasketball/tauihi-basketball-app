import Foundation
import Combine

@MainActor
class DataManager: ObservableObject {
    // MARK: - Published Properties
    @Published var newsPosts: [WPPost] = []
    @Published var teams: [Team] = []
    @Published var games: [Match] = []
    @Published var standings: [Standing] = []
    @Published var liveGames: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Services
    private let wordPressService = WordPressService()
    private let sportsService: SportsDataService
    private let backendService = BackendService()
    
    // MARK: - Cache
    private var cache: [String: Any] = [:]
    private var cacheTimestamps: [String: Date] = [:]
    
    // MARK: - ID Mapping (for converting between Int IDs from API and UUIDs from models)
    private var teamIdMapping: [Int: UUID] = [:]
    private var standingIdMapping: [Int: UUID] = [:]
    
    init() {
        // Use appropriate service based on environment
        if Environment.current == .production {
            self.sportsService = BackendService()
        } else {
            self.sportsService = GeniusSportsService(apiKey: APIConfig.geniusSportsAPIKey)
        }
        
        // Load initial data
        Task {
            await loadAllData()
        }
    }
    
    // MARK: - News Data
    func loadNews() async {
        isLoading = true
        errorMessage = nil
        
        do {
            newsPosts = try await WordPressService.fetchPosts()
        } catch {
            errorMessage = "Failed to load news: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Sports Data
    func loadTeams() async {
        isLoading = true
        errorMessage = nil
        
        do {
            teams = try await sportsService.fetchTeams(leagueId: APIConfig.tauihiLeagueId)
        } catch {
            errorMessage = "Failed to load teams: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func loadGames() async {
        isLoading = true
        errorMessage = nil
        
        do {
            games = try await sportsService.fetchGames(competitionId: APIConfig.tauihiCompetitionId)
        } catch {
            errorMessage = "Failed to load games: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func loadStandings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            standings = try await sportsService.fetchStandings(competitionId: APIConfig.tauihiCompetitionId)
        } catch {
            errorMessage = "Failed to load standings: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func loadLiveGames() async {
        isLoading = true
        errorMessage = nil
        
        do {
            liveGames = try await sportsService.fetchLiveGames(competitionId: APIConfig.tauihiCompetitionId)
        } catch {
            errorMessage = "Failed to load live games: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Combined Data Loading
    func loadAllData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadNews() }
            group.addTask { await self.loadTeams() }
            group.addTask { await self.loadGames() }
            group.addTask { await self.loadStandings() }
            group.addTask { await self.loadLiveGames() }
        }
    }
    
    // MARK: - Cache Management
    private func getCachedData<T>(for key: String) -> T? {
        guard let timestamp = cacheTimestamps[key],
              Date().timeIntervalSince(timestamp) < APIConfig.Limits.cacheExpiration,
              let data = cache[key] as? T else {
            return nil
        }
        return data
    }
    
    private func setCachedData<T>(_ data: T, for key: String) {
        cache[key] = data
        cacheTimestamps[key] = Date()
    }
    
    // MARK: - Data Helpers
    func getUpcomingGames() -> [Match] {
        return games.filter { match in
            guard let scheduledTime = ISO8601DateFormatter().date(from: match.scheduledTime) else {
                return false
            }
            return scheduledTime > Date() && match.status.lowercased() != "finished"
        }.sorted { match1, match2 in
            guard let time1 = ISO8601DateFormatter().date(from: match1.scheduledTime),
                  let time2 = ISO8601DateFormatter().date(from: match2.scheduledTime) else {
                return false
            }
            return time1 < time2
        }
    }
    
    func getLiveGames() -> [Match] {
        return liveGames.filter { match in
            match.status.lowercased() == "live" || match.status.lowercased() == "in_progress"
        }
    }
    
    func getFinishedGames() -> [Match] {
        return games.filter { match in
            match.status.lowercased() == "finished" || match.status.lowercased() == "completed"
        }.sorted { match1, match2 in
            guard let time1 = ISO8601DateFormatter().date(from: match1.scheduledTime),
                  let time2 = ISO8601DateFormatter().date(from: match2.scheduledTime) else {
                return false
            }
            return time1 > time2
        }
    }
    
    func getTeam(by id: Int) -> Team? {
        // Try to find team by mapped UUID first
        if let uuid = teamIdMapping[id] {
            return teams.first { $0.id == uuid }
        }
        // Fallback to first team if no mapping exists
        return teams.first
    }
    
    func getTeamName(by id: Int) -> String {
        return getTeam(by: id)?.name ?? "Unknown Team"
    }
    
    func getStanding(for teamId: Int) -> Standing? {
        // Try to find standing by mapped UUID first
        if let uuid = standingIdMapping[teamId] {
            return standings.first { $0.id == uuid }
        }
        // Fallback to first standing if no mapping exists
        return standings.first
    }
    
    func getPlayer(by id: Int) -> Player? {
        // This would need to be implemented with player data
        return nil
    }
    
    // MARK: - Backend Integration
    func loadTeamsFromBackend(leagueId: Int) async throws -> [Team] {
        do {
            let response: BackendResponse<[Team]> = try await backendService.fetch(endpoint: "teams?leagueId=\(leagueId)")
            if response.success {
                return response.data ?? []
            } else {
                throw BackendError.apiError(message: "Failed to load teams from backend")
            }
        } catch {
            throw error
        }
    }
    
    func loadGamesFromBackend(competitionId: Int) async throws -> [Game] {
        do {
            let response: BackendResponse<[Game]> = try await backendService.fetch(endpoint: "games?competitionId=\(competitionId)")
            if response.success {
                return response.data ?? []
            } else {
                throw BackendError.apiError(message: "Failed to load games from backend")
            }
        } catch {
            throw error
        }
    }
    
    func loadStandingsFromBackend(competitionId: Int) async throws -> [Standing] {
        do {
            let response: BackendResponse<[Standing]> = try await backendService.fetch(endpoint: "standings?competitionId=\(competitionId)")
            if response.success {
                return response.data ?? []
            } else {
                throw BackendError.apiError(message: "Failed to load standings from backend")
            }
        } catch {
            throw error
        }
    }
    
    func loadPlayersFromBackend(for teamId: Int) async -> [Player] {
        do {
            let response: BackendResponse<[Player]> = try await backendService.fetch(endpoint: "players?teamId=\(teamId)")
            if response.success {
                return response.data ?? []
            } else {
                errorMessage = "Failed to load players from backend"
                return []
            }
        } catch {
            errorMessage = "Failed to load players: \(error.localizedDescription)"
            return []
        }
    }
}

// MARK: - Sports Data Service Protocol
protocol SportsDataService {
    func fetchTeams(leagueId: Int) async throws -> [Team]
    func fetchGames(competitionId: Int) async throws -> [Match]
    func fetchLiveGames(competitionId: Int) async throws -> [Match]
    func fetchStandings(competitionId: Int) async throws -> [Standing]
    func fetchPlayers(teamId: Int) async throws -> [Player]
    func fetchTeamStatistics(teamId: Int, competitionId: Int) async throws -> [TeamStatistic]
    func fetchPlayerStatistics(playerId: Int, competitionId: Int) async throws -> [PersonStatistic]
}

// MARK: - Extensions
extension Match {
    var isLive: Bool {
        return status.lowercased() == "inprogress"
    }
    
    var isUpcoming: Bool {
        guard let scheduledTime = ISO8601DateFormatter().date(from: scheduledTime) else {
            return false
        }
        return scheduledTime > Date() && !isLive
    }
    
    var formattedDate: String {
        guard let date = ISO8601DateFormatter().date(from: scheduledTime) else {
            return scheduledTime
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    var formattedTime: String {
        guard let date = ISO8601DateFormatter().date(from: scheduledTime) else {
            return scheduledTime
        }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 