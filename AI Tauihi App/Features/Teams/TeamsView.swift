import SwiftUI

struct TeamsView: View {
    @StateObject private var viewModel = TeamsViewModel()
    @State private var selectedTeam: Team? = nil

    let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Loading teams...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.tauihiRed)
                            .padding()
                        Text("Error loading teams")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            Task {
                                await viewModel.loadTeams()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.tauihiRed)
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else if viewModel.teams.isEmpty {
                    VStack {
                        Image(systemName: "person.3")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                            .padding()
                        Text("No teams found")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Check back later for team information")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.teams) { team in
                            Button {
                                selectedTeam = team
                            } label: {
                                TeamCardView(team: team)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Teams")
            .sheet(item: $selectedTeam) { team in
                TeamDetailView(team: team)
            }
            .refreshable {
                await viewModel.loadTeams()
            }
        }
        .onAppear {
            if viewModel.teams.isEmpty {
                Task {
                    await viewModel.loadTeams()
                }
            }
        }
    }
}

class TeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @MainActor
    private let dataManager = DataManager()
    
    @MainActor
    func loadTeams() async {
        isLoading = true
        errorMessage = nil
        
        do {
            teams = try await dataManager.loadTeamsFromBackend(leagueId: 1)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    TeamsView()
} 