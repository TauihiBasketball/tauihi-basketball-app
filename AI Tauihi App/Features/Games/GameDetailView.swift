import SwiftUI

struct GameDetailView: View, Identifiable {
    let id = UUID()
    let game: Game

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 32) {
                VStack {
                    AsyncImage(url: game.homeTeam.logoURL) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    Text(game.homeTeam.name)
                        .font(.headline)
                }
                VStack {
                    if let home = game.homeScore, let away = game.awayScore {
                        HStack(spacing: 4) {
                            Text("\(home)")
                                .font(.largeTitle).bold()
                            Text(":" )
                                .font(.largeTitle)
                            Text("\(away)")
                                .font(.largeTitle).bold()
                        }
                    } else {
                        Text(formattedDate)
                            .font(.title2)
                        Text(formattedTime)
                            .font(.title2).bold()
                    }
                    Text(game.venue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                VStack {
                    AsyncImage(url: game.awayTeam.logoURL) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    Text(game.awayTeam.name)
                        .font(.headline)
                }
            }
            Divider()
            Text("Box Score & Stats coming soon...")
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
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