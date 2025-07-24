import SwiftUI

struct StandingsView: View {
    @StateObject private var viewModel = StandingsViewModel()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Loading standings...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.tauihiRed)
                            .padding()
                        Text("Error loading standings")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            Task {
                                await viewModel.loadStandings()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.tauihiRed)
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Text("#").bold().frame(width: 30)
                                Text("Team").bold().frame(maxWidth: .infinity, alignment: .leading)
                                Text("W").bold().frame(width: 30)
                                Text("L").bold().frame(width: 30)
                                Text("PCT").bold().frame(width: 50)
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            
                            Divider()
                            
                            // Standings rows
                            ForEach(viewModel.standings) { standing in
                                HStack {
                                    Text("\(standing.rank)")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .frame(width: 30)
                                        .foregroundColor(standing.rank <= 4 ? .tauihiRed : .primary)
                                    
                                    HStack(spacing: 8) {
                                        AsyncImage(url: standing.team.logoURL) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            Circle()
                                                .fill(Color(.systemGray4))
                                                .overlay(
                                                    Text(initials(for: standing.team.name))
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.white)
                                                )
                                        }
                                        .frame(width: 24, height: 24)
                                        .clipShape(Circle())
                                        
                                        Text(standing.team.name)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("\(standing.wins)")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .frame(width: 30)
                                        .foregroundColor(.primary)
                                    
                                    Text("\(standing.losses)")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .frame(width: 30)
                                        .foregroundColor(.primary)
                                    
                                    Text(String(format: "%.3f", standing.percent))
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .frame(width: 50)
                                        .foregroundColor(.primary)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(standing.rank <= 4 ? Color.tauihiRed.opacity(0.05) : Color.clear)
                                
                                if standing.id != viewModel.standings.last?.id {
                                    Divider()
                                        .padding(.leading, 70)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ladder")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadStandings()
            }
        }
        .onAppear {
            if viewModel.standings.isEmpty {
                Task {
                    await viewModel.loadStandings()
                }
            }
        }
    }
    
    private func initials(for name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))"
        } else {
            return String(name.prefix(2))
        }
    }
}

class StandingsViewModel: ObservableObject {
    @Published var standings: [Standing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @MainActor
    private let dataManager = DataManager()
    
    @MainActor
    func loadStandings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            standings = try await dataManager.loadStandingsFromBackend(competitionId: 40145)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    StandingsView()
} 