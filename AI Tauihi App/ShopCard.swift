import SwiftUI

struct ShopCard: View {
    let title: String
    let icon: String
    var body: some View {
        VStack {
            Image(systemName: icon).font(.largeTitle)
            Text(title)
        }
        .frame(width: 150, height: 100)
        .background(Color.tauihiRed)
        .foregroundColor(.white)
        .cornerRadius(12)
    }
} 