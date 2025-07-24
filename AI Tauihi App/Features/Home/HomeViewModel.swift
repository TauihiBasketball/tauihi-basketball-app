import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var standings: [Team] = []
    @Published var games: [Game] = []
    @Published var upcomingGames: [Game] = []
    @Published var liveGames: [Game] = []
    @Published var articles: [Article] = []
    
    @Published var isLoadingGames = false
    @Published var gamesErrorMessage: String?
    
    private let dataManager = DataManager()
    
    func loadGames() async {
        isLoadingGames = true
        gamesErrorMessage = nil
        
        do {
            games = try await dataManager.loadGamesFromBackend(competitionId: 40145)
            upcomingGames = games.filter { $0.status.lowercased() == "upcoming" }.prefix(7).map { $0 }
            liveGames = games.filter { $0.status.lowercased() == "live" }
        } catch {
            gamesErrorMessage = error.localizedDescription
        }
        
        isLoadingGames = false
    }
    
    func fetchHomeData() async {
        await loadGames()
        // Add other data fetching as needed
    }
} 