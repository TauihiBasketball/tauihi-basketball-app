import Foundation

struct BoxScorePlayerStat: Codable, Identifiable {
    var id = UUID()
    let playerName: String
    let points: Int
    let rebounds: Int
    let assists: Int
    let steals: Int
    let blocks: Int
}

@MainActor
class BoxScoreViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var stats: [BoxScorePlayerStat] = []
    @Published var noStatsMessage: String?
    @Published var errorMessage: String?

    func fetchStats(matchId: String, gameDateString: String) async {
        isLoading = true
        stats = []
        noStatsMessage = nil
        errorMessage = nil

        do {
            // Parse the game date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let gameDate = dateFormatter.date(from: gameDateString) else {
                self.noStatsMessage = "Invalid game date."
                self.isLoading = false
                return
            }

            // Check if the game is in the future
            let now = Date()
            if gameDate > now {
                self.noStatsMessage = "Stats will be available once the game starts or ends."
                self.isLoading = false
                return
            }

            // Replace with your own Google Apps Script endpoint
            guard let url = URL(string: "https://script.google.com/macros/s/AKfycbz3waGq__-FviN4Zdt7yKkuTDDVfrp1Gk8-TRP3JGBHZebMvWkySSqpqqLeN_SVUPNN/exec?matchId=\(matchId)") else {
                throw BoxScoreError.invalidURL
            }

            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw BoxScoreError.invalidResponse
            }

            let result = try JSONDecoder().decode([BoxScorePlayerStat].self, from: data)
            if result.isEmpty {
                self.noStatsMessage = "No stats available yet."
            } else {
                self.stats = result
            }
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Error fetching stats: \(error)")
        }
        
        self.isLoading = false
    }
}

enum BoxScoreError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        }
    }
} 