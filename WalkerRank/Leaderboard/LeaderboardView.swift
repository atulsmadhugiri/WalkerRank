import SwiftUI

struct LeaderboardView: View {
  @State private var selectedScope: LeaderboardScope = .global

  var body: some View {
    NavigationView {
      VStack {
        Picker("Leaderboard Scope", selection: $selectedScope) {
          ForEach(LeaderboardScope.allCases, id: \.self) { scope in
            Text(scope.rawValue).tag(scope)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.init(top: 18, leading: 14, bottom: 0, trailing: 18))

        VStack {
          List(
            dummyData(for: selectedScope).enumerated().map { (index, entry) in
              (index + 1, entry)
            }, id: \.1.id
          ) { (position, entry) in

            LeaderboardRow(position: position, entry: entry)
          }
          .listStyle(.plain)
          .background(.background)
          .cornerRadius(8)
          .shadow(radius: 2)
        }.padding(.init(top: 4, leading: 16, bottom: 16, trailing: 16))

      }
      .navigationTitle("Leaderboard")
      .background(.ultraThickMaterial)

    }
  }

  private func dummyData(for scope: LeaderboardScope) -> [LeaderboardEntry] {
    switch scope {
    case .global:
      return globalLeaderboardEntries
    case .state:
      return stateLeaderboardEntries
    case .city:
      return cityLeaderboardEntries
    }
  }
}

struct LeaderboardEntry: Identifiable {
  let id = UUID()
  let profilePictureURL: URL
  let firstName: String
  let stepsLastWeek: Int
  let lastUpdated: String
}

enum LeaderboardScope: String, CaseIterable {
  case global = "Global"
  case state = "State"
  case city = "City"
}

let globalLeaderboardEntries = [
  LeaderboardEntry(
    profilePictureURL: URL(
      string: "https://blob.sh/atul.png")!,
    firstName: "Atul", stepsLastWeek: 13402, lastUpdated: "1 hour ago"),
  LeaderboardEntry(
    profilePictureURL: URL(
      string: "https://blob.sh/faces/002.jpg")!,
    firstName: "Jessica", stepsLastWeek: 12392, lastUpdated: "2 hours ago"),
  LeaderboardEntry(
    profilePictureURL: URL(
      string: "https://blob.sh/faces/109.jpg")!,
    firstName: "Mitch", stepsLastWeek: 11932, lastUpdated: "2 hours ago"),
  LeaderboardEntry(
    profilePictureURL: URL(
      string:
        "https://blob.sh/faces/120.jpg"
    )!, firstName: "Harper", stepsLastWeek: 8313, lastUpdated: "3 hours ago"),
  LeaderboardEntry(
    profilePictureURL: URL(
      string:
        "https://blob.sh/faces/038.jpg"
    )!, firstName: "Sophia", stepsLastWeek: 6431, lastUpdated: "3 hours ago"),
  LeaderboardEntry(
    profilePictureURL: URL(
      string:
        "https://blob.sh/faces/031.jpg"
    )!, firstName: "Will", stepsLastWeek: 5985, lastUpdated: "3 hours ago"),
]

let stateLeaderboardEntries = globalLeaderboardEntries

let cityLeaderboardEntries = globalLeaderboardEntries

#Preview {
  LeaderboardView()
}
