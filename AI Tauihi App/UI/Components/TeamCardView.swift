import SwiftUI

struct TeamCardView: View {
    let team: Team

    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: team.logoURL) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            Text(team.name)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
} 