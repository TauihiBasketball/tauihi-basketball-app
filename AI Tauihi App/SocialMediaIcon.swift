import SwiftUI

struct SocialMediaIcon: View {
    let imageName: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(Color.tauihiRed)
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
        }
        .frame(width: 50, height: 50)
    }
} 