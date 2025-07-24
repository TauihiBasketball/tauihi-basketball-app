import Foundation

struct APIConfig {
    // MARK: - Genius Sports API
    static let geniusSportsAPIKey = "4b1a43036f40c7762a694255636eab03"
    
    // MARK: - WordPress API
    static let wordPressBaseURL = "https://www.tauihi.basketball/wp-json/wp/v2"
    
    // MARK: - Tauihi League Configuration
    static let tauihiLeagueId = 1 // Replace with actual Tauihi league ID
    static let tauihiCompetitionId = 1 // Replace with actual competition ID
    
    // MARK: - API Endpoints
    struct Endpoints {
        static let geniusSportsREST = "https://api.wh.geniussports.com/v1/basketball"
        static let geniusSportsLivestream = "https://live.wh.geniussports.com/v2/basketball/read"
        static let wordPress = "https://www.tauihi.basketball/wp-json/wp/v2"
        
        // Your deployed Vercel backend
        static let backendAPI = "https://tauihi-backend-cqxe8y0zp-tauihibasketballs-projects.vercel.app/api"
    }
    
    // MARK: - Request Limits
    struct Limits {
        static let maxRetries = 3
        static let timeoutInterval: TimeInterval = 30
        static let cacheExpiration: TimeInterval = 300 // 5 minutes
        static let apiQuotaLimit = 250000 // 250k API calls
    }
    
    // MARK: - Cache Settings
    struct Cache {
        static let newsExpiration: TimeInterval = 1800 // 30 minutes
        static let standingsExpiration: TimeInterval = 600 // 10 minutes
        static let gamesExpiration: TimeInterval = 300 // 5 minutes
        static let liveDataExpiration: TimeInterval = 30 // 30 seconds
    }
}

// MARK: - Environment Configuration
enum Environment {
    case development
    case production
    
    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    var baseURL: String {
        switch self {
        case .development:
            return APIConfig.Endpoints.geniusSportsREST
        case .production:
            return APIConfig.Endpoints.backendAPI // Use backend in production
        }
    }
}

// MARK: - API Response Models for Backend Integration
struct BackendResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
    let timestamp: Date
    let cached: Bool
} 