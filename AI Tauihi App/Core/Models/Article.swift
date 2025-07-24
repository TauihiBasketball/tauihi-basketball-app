import Foundation

struct Article: Identifiable, Codable, Equatable {
    let id: UUID
    let headline: String
    let thumbnailURL: URL
    let publishedAt: Date
    let url: URL
} 