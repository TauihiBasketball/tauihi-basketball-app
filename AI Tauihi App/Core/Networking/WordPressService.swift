import Foundation

class WordPressService {
    static func fetchPosts() async throws -> [WPPost] {
        let url = URL(string: "https://tauihi.basketball/wp-json/wp/v2/posts?_embed")!
        let (data, _) = try await URLSession.shared.data(from: url)
        var posts = try JSONDecoder().decode([WPPost].self, from: data)
        let raw = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
        for i in 0..<posts.count {
            if let embedded = raw[i]["_embedded"] as? [String: Any],
               let media = (embedded["wp:featuredmedia"] as? [[String: Any]])?.first,
               let imageURL = media["source_url"] as? String {
                posts[i].featuredImageURL = URL(string: imageURL)
            }
        }
        return posts
    }
} 