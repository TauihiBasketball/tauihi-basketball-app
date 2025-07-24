import Foundation

struct TeamService {
    static func fetch() async throws -> [Team] {
        guard let url = URL(string: "https://docs.google.com/spreadsheets/d/e/2PACX-1vTZi23D0oQDDskCgnaavSkPbCXSf30Re-8pu4MJvNbHsD8YhYQtGoEzq_g-P9V3K6wKOBrJVPDEzWZX/pub?gid=270581745&single=true&output=csv") else {
            throw TeamServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TeamServiceError.invalidResponse
        }
        
        guard let content = String(data: data, encoding: .utf8) else {
            throw TeamServiceError.invalidData
        }
        
        let rows = content.components(separatedBy: "\n").dropFirst()
        let teams = rows.compactMap { row -> Team? in
            let columns = row.components(separatedBy: ",")
            guard columns.count >= 3,
                  let logoURL = URL(string: columns[1]) else {
                return nil
            }
            return Team(
                id: UUID(),
                name: columns[0],
                logoURL: logoURL,
                coach: "TBD",
                website: URL(string: "https://tauihi.basketball")!,
                roster: Player.samplePlayers
            )
        }
        
        return teams
    }
}

enum TeamServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .invalidData:
            return "Invalid data format"
        }
    }
} 
 