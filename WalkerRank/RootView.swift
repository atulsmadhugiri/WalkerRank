import SwiftUI

struct RootView: View {
  var body: some View {
    TabView {
      ContentView().tabItem {
        Label("Steps", systemImage: "figure.walk")
      }
    }
  }
}

#Preview {
  RootView()
}
