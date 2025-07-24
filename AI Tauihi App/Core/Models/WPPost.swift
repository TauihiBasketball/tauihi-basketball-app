import Foundation

struct WPPost: Identifiable, Decodable {
    let id: Int
    let title: RenderedText
    let excerpt: RenderedText
    let content: RenderedText
    let link: String
    let featured_media: Int
    var featuredImageURL: URL?

    struct RenderedText: Decodable {
        let rendered: String
    }
} 