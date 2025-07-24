import SwiftUI

struct TeamDetailView: View, Identifiable {
    let id = UUID()
    let team: Team

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                AsyncImage(url: team.logoURL) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                Text(team.name)
                    .font(.largeTitle)
                    .bold()
                Text("Coach: \(team.coach)")
                    .font(.headline)
                Link("Visit Team Website", destination: team.website)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Roster")
                        .font(.title2).bold()
                    ForEach(team.roster) { player in
                        HStack {
                            Text("#\(player.number)")
                                .font(.body).bold()
                                .frame(width: 36, alignment: .leading)
                            Text(player.name)
                                .font(.body)
                            Spacer()
                            Text(player.position)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top)
            }
            .padding()
        }
    }
} 