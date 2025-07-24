import SwiftUI

struct LiveScoreBanner: View {
    let game: Game
    
    var body: some View {
        HStack {
            Text("LIVE")
                .font(.tauihiCaption)
                .bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.tauihiRed)
                .cornerRadius(6)
            Text("\(game.homeTeam.name) \(game.homeScore ?? 0) - \(game.awayScore ?? 0) \(game.awayTeam.name)")
                .font(.tauihiBody)
                .bold()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color.tauihiRed)
        .foregroundColor(.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    LiveScoreBanner(game: Game(
        id: UUID(),
        homeTeam: Team.sampleTeams[0],
        awayTeam: Team.sampleTeams[1],
        scheduledTime: ISO8601DateFormatter().string(from: Date()),
        venue: "Eventfinda Stadium",
        homeScore: 68,
        awayScore: 65,
        status: "live"
    ))
} 