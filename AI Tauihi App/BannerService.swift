import Foundation

class BannerService {
    static let csvURL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTZi23D0oQDDskCgnaavSkPbCXSf30Re-8pu4MJvNbHsD8YhYQtGoEzq_g-P9V3K6wKOBrJVPDEzWZX/pub?gid=1691775758&single=true&output=csv"

    static func fetch() async throws -> [Banner] {
        guard let url = URL(string: csvURL) else {
            throw BannerServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BannerServiceError.invalidResponse
        }
        
        guard let raw = String(data: data, encoding: .utf8) else {
            throw BannerServiceError.invalidData
        }

        let lines = raw.components(separatedBy: .newlines).dropFirst()
        let banners = lines.compactMap { line -> Banner? in
            let parts = line.components(separatedBy: ",")
            guard parts.count >= 2,
                  let image = URL(string: parts[1]) else { return nil }
            return Banner(type: parts[0], imageURL: image)
        }

        return banners
    }
}

enum BannerServiceError: Error, LocalizedError {
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