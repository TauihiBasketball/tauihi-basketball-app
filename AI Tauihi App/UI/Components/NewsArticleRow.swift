import SwiftUI

struct NewsArticleRow: View {
    let article: Article
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            AsyncImage(url: article.thumbnailURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(Color.tauihiRed.opacity(0.2))
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityLabel("Thumbnail for article: \(article.headline)")
            VStack(alignment: .leading, spacing: 6) {
                Text(article.headline)
                    .font(.tauihiHeadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Text(article.publishedAt, style: .relative)
                    .font(.tauihiCaption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(article.headline)
    }
}

#Preview {
    NewsArticleRow(article: .init(
        id: UUID(),
        headline: "Tauihi Basketball: Big Win for Whai!",
        thumbnailURL: URL(string: "https://example.com")!,
        publishedAt: Date().addingTimeInterval(-3600),
        url: URL(string: "https://tauihi.basketball/news/1")!
    ))
} 