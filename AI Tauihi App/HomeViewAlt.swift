import SwiftUI

struct HomeViewAlt: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var posts: [WPPost] = []
    @State private var selectedPost: WPPost? = nil
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedGameIndex: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                HStack {
                    Image("TauihiLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.tauihiRed)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Games Carousel
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Games", color: .tauihiRed)
                    
                    if homeViewModel.isLoadingGames {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.2)
                                .padding()
                            Text("Loading games...")
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 200)
                    } else if let gamesError = homeViewModel.gamesErrorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.tauihiRed)
                                .padding()
                            Text("Error loading games")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(gamesError)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(height: 200)
                    } else if homeViewModel.games.isEmpty {
                        VStack {
                            Image(systemName: "calendar.badge.plus")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                                .padding()
                            Text("No games scheduled")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Check back later for upcoming games")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(height: 200)
                    } else {
                        ZStack(alignment: .bottom) {
                            TabView(selection: $selectedGameIndex) {
                                ForEach(homeViewModel.games.indices, id: \.self) { index in
                                    ProGameCardView(game: homeViewModel.games[index])
                                        .padding(.horizontal, 8)
                                        .tag(index)
                                        .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 4)
                                        .scaleEffect(selectedGameIndex == index ? 1.0 : 0.97)
                                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedGameIndex)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .frame(height: 200)
                            
                            // Modern page indicators
                            HStack(spacing: 8) {
                                ForEach(homeViewModel.games.indices, id: \.self) { idx in
                                    Capsule()
                                        .fill(idx == selectedGameIndex ? Color.tauihiRed : Color.gray.opacity(0.3))
                                        .frame(width: idx == selectedGameIndex ? 24 : 8, height: 8)
                                        .animation(.easeInOut, value: selectedGameIndex)
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                .padding(.top, 4)

                // News Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "News", color: .tauihiRed)
                    if isLoading {
                        ProgressView("Loading news...")
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 24) {
                                ForEach(posts) { post in
                                    Button {
                                        selectedPost = post
                                    } label: {
                                        ProNewsCardView(post: post)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                Spacer(minLength: 0)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .sheet(item: $selectedPost) { post in
            ArticleDetailView(post: post) {
                selectedPost = nil
            }
        }
        .refreshable {
            await homeViewModel.loadGames()
            await loadNews()
        }
        .onAppear { 
            Task { 
                await homeViewModel.loadGames()
                await loadNews() 
            } 
        }
    }

    @MainActor
    func loadNews() async {
        isLoading = true
        errorMessage = nil
        do {
            posts = try await WordPressService.fetchPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func stripHTML(_ html: String) -> String {
        guard let data = html.data(using: .utf16) else { return html }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf16.rawValue
        ]
        return (try? NSAttributedString(data: data, options: options, documentAttributes: nil))?.string ?? html
    }
}

struct SectionHeader: View {
    let title: String
    let color: Color
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.title2).bold()
                .foregroundColor(.primary)
            Image(systemName: "chevron.right")
                .foregroundColor(color)
        }
        .padding(.horizontal, 2)
        .padding(.bottom, 2)
    }
}

struct ProGameCardView: View {
    let game: Game
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    let url = game.homeTeam.logoURL
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color(.systemGray4))
                            .overlay(Text(initials(for: game.homeTeam.name)).font(.headline).foregroundColor(.white))
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    Text(game.homeTeam.name)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                }
                VStack(spacing: 4) {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formattedTime)
                        .font(.title2).bold()
                        .foregroundColor(.tauihiRed)
                    Text(game.venue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if game.status.lowercased() == "live" {
                        Text("LIVE")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.tauihiRed)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                    } else if game.status.lowercased() == "upcoming" {
                        Text("UPCOMING")
                            .font(.caption2.bold())
                            .foregroundColor(.tauihiRed)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                VStack(spacing: 4) {
                    let url = game.awayTeam.logoURL
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color(.systemGray4))
                            .overlay(Text(initials(for: game.awayTeam.name)).font(.headline).foregroundColor(.white))
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    Text(game.awayTeam.name)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: game.date)
    }
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: game.date)
    }
    func initials(for name: String) -> String {
        let comps = name.split(separator: " ")
        return comps.prefix(2).map { String($0.prefix(1)) }.joined().uppercased()
    }
}

struct ProNewsCardView: View {
    let post: WPPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Featured image with 1920x1080 aspect ratio - fixed height
            if let imageURL = post.featuredImageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.tauihiRed.opacity(0.1))
                        .overlay(
                            Image(systemName: "newspaper")
                                .font(.title2)
                                .foregroundColor(.tauihiRed)
                        )
                }
                .frame(height: 160)
                .clipped()
                .cornerRadius(12, corners: [.topLeft, .topRight])
            }
            
            // Content area with fixed height to ensure consistency
            VStack(alignment: .leading, spacing: 8) {
                // Title - with fixed height to prevent layout issues
                Text(stripHTML(post.title.rendered))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(height: 48, alignment: .top)
                
                // Read more button - always visible at bottom
                HStack {
                    Text("Read more")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.tauihiRed)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.tauihiRed)
                }
            }
            .padding(16)
            .frame(height: 80)
            .background(Color(.systemBackground))
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .frame(width: 280, height: 240)
    }
    
    func stripHTML(_ html: String) -> String {
        guard let data = html.data(using: .utf16) else { return html }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf16.rawValue
        ]
        return (try? NSAttributedString(data: data, options: options, documentAttributes: nil))?.string ?? html
    }
}

// Extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#if DEBUG
struct HomeViewAlt_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewAlt()
    }
}
#endif 