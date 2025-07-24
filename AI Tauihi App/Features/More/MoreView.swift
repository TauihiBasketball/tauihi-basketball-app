import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Shop")) {
                    Link("Tauihi Shop", destination: URL(string: "https://stirlingsports.co.nz/pages/nznbl")!)
                }
                Section(header: Text("Social")) {
                    Link("Facebook", destination: URL(string: "https://www.facebook.com/TauihiNZ")!)
                    Link("Instagram", destination: URL(string: "https://www.instagram.com/tauihinz")!)
                    Link("TikTok", destination: URL(string: "https://www.tiktok.com/@tauihinz")!)
                    Link("Twitter/X", destination: URL(string: "https://x.com/TauihiNZ")!)
                }
                Section(header: Text("About")) {
                    Text("Tauihi Basketball Aotearoa is New Zealand's premier women's basketball league.")
                }
            }
            .navigationTitle("More")
        }
    }
} 