import Foundation

class GameServiceAPI {
    static let shared = GameServiceAPI()
    
    private init() {}
    
    func fetchGames() async throws -> [GameAPI] {
        guard let url = URL(string: "https://script.google.com/macros/s/AKfycbywuuc1m4rIeHtR_u8KmGavcWOhOHfG8XIzDfTH0JBh_eWgnvoPIpI3bu-co9yT1cTK/exec") else {
            throw GameServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GameServiceError.invalidResponse
        }
        
        do {
            let games = try JSONDecoder().decode([GameAPI].self, from: data)
            return games.sorted { game1, game2 in
                (game1.date + game1.time) < (game2.date + game2.time)
            }
        } catch {
            throw GameServiceError.decodingError(error)
        }
    }
}

enum GameServiceError: Error, LocalizedError {
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