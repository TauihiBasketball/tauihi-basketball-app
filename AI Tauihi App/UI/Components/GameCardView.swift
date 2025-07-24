import SwiftUI

struct GameCardView: View {
    let game: Game
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(spacing: 16) {
                VStack {
                    AsyncImage(url: game.homeTeam.logoURL) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    Text(game.homeTeam.name)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                VStack {
                    Text(game.status == "final" ? "Final" : formattedDate)
                        .font(.headline)
                        .foregroundColor(game.status == "final" ? .gray : .orange)
                    if let home = game.homeScore, let away = game.awayScore {
                        HStack(spacing: 4) {
                            Text("\(home)")
                                .font(.title2).bold()
                            Text(":" )
                                .font(.title2)
                            Text("\(away)")
                                .font(.title2).bold()
                        }
                    } else {
                        Text(formattedTime)
                            .font(.title2).bold()
                            .foregroundColor(.orange)
                    }
                    Text(game.venue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                VStack {
                    AsyncImage(url: game.awayTeam.logoURL) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    Text(game.awayTeam.name)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 2)
        .frame(maxWidth: .infinity)
    }
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: game.date)
    }
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: game.date)
    }
}

#Preview {
    GameCardView(game: Game(
        id: UUID(),
        homeTeam: Team.sampleTeams[0],
        awayTeam: Team.sampleTeams[1],
        scheduledTime: ISO8601DateFormatter().string(from: Date()),
        venue: "Eventfinda Stadium",
        homeScore: 0,
        awayScore: 0,
        status: "upcoming"
    ))
} 