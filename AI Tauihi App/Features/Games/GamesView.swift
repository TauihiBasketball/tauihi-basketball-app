import SwiftUI

struct GamesView: View {
    @StateObject private var viewModel = GamesViewModel()
    @State private var selectedGame: Game? = nil
    @State private var selectedIndex: Int = 0

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Games")
                        .font(.title2).bold()
                        .padding(.leading)
                    Spacer()
                    Button("Buy Tickets") {}
                        .font(.subheadline)
                        .padding(.trailing)
                        .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 8)
                
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Loading games...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.tauihiRed)
                            .padding()
                        Text("Error loading games")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            Task {
                                await viewModel.loadGames()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.tauihiRed)
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.games.isEmpty {
                    VStack {
                        Image(systemName: "calendar.badge.plus")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                            .padding()
                        Text("No games scheduled")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Check back later for upcoming games")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    TabView(selection: $selectedIndex) {
                        ForEach(viewModel.games.indices, id: \.self) { index in
                            let game = viewModel.games[index]
                            GameCardView(game: game)
                                .onTapGesture { selectedGame = game }
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 180)
                    .padding(.bottom)
                    
                    // Games list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.games) { game in
                                GameCardView(game: game)
                                    .onTapGesture { selectedGame = game }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("")
            .sheet(item: $selectedGame) { game in
                GameDetailView(game: game)
            }
            .refreshable {
                await viewModel.loadGames()
            }
        }
        .onAppear {
            if viewModel.games.isEmpty {
                Task {
                    await viewModel.loadGames()
                }
            }
        }
    }
}

class GamesViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @MainActor
    private let dataManager = DataManager()
    
    @MainActor
    func loadGames() async {
        isLoading = true
        errorMessage = nil
        
        do {
            games = try await dataManager.loadGamesFromBackend(competitionId: 40145)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    GamesView()
} 