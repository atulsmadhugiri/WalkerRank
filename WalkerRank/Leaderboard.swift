import SwiftUI

struct Leaderboard: View {
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

struct LeaderboardRow: View {
  let position: Int
  let entry: LeaderboardEntry

  var body: some View {
    HStack(spacing: 16) {

      ZStack(alignment: .bottomTrailing) {
        AsyncImage(url: entry.profilePictureURL) { image in
          image.resizable()
        } placeholder: {
          ProgressView()
        }
        .frame(width: 60, height: 60)
        .cornerRadius(16)

        Image(systemName: "seal.fill")
          .resizable()
          .frame(width: 25, height: 25)
          .foregroundColor(badgeColor(for: position))
          .overlay(
            Text("\(position)")
              .font(.caption).fontWeight(.black).fontDesign(.rounded)
              .foregroundColor(.white)
          )
          .offset(x: 5, y: 5)
          .shadow(radius: 1)
      }

      VStack(alignment: .leading) {
        Text(entry.firstName)
          .font(.headline).fontDesign(.rounded)
      }
      Spacer()
      VStack(alignment: .trailing) {
        Text("\(entry.stepsLastWeek) steps")
          .font(.headline).fontDesign(.rounded).foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 2)
  }

  private func badgeColor(for position: Int) -> Color {
    switch position {
    case 1:
      return .yellow
    case 2:
      return .gray
    case 3:
      return .orange
    default:
      return .secondary
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
      string: "https://picsum.photos/50/50")!,
    firstName: "Bob", stepsLastWeek: 13402, lastUpdated: "1 hour ago"),
  LeaderboardEntry(
    profilePictureURL: URL(
      string: "https://picsum.photos/50/50")!,
    firstName: "Gerald", stepsLastWeek: 12392, lastUpdated: "2 hours ago"),
  LeaderboardEntry(
    profilePictureURL: URL(
      string:
        "https://picsum.photos/50/50"
    )!, firstName: "Obama", stepsLastWeek: 10239, lastUpdated: "3 hours ago"),
]

let stateLeaderboardEntries = [
  LeaderboardEntry(
    profilePictureURL: URL(string: "https://picsum.photos/50/50")!,
    firstName: "Chris", stepsLastWeek: 110000, lastUpdated: "4 hours ago"),
  LeaderboardEntry(
    profilePictureURL: URL(string: "https://picsum.photos/50/50")!,
    firstName: "Sam", stepsLastWeek: 105500, lastUpdated: "5 hours ago"),
  LeaderboardEntry(
    profilePictureURL: URL(string: "https://picsum.photos/50/50")!,
    firstName: "Morgan", stepsLastWeek: 98000, lastUpdated: "6 hours ago"),
]

let cityLeaderboardEntries = [
  LeaderboardEntry(
    profilePictureURL: URL(string: "https://picsum.photos/50/50")!,
    firstName: "Pat", stepsLastWeek: 94000, lastUpdated: "7 hours ago"),
  LeaderboardEntry(
    profilePictureURL: URL(string: "https://picsum.photos/50/50")!,
    firstName: "Casey", stepsLastWeek: 91000, lastUpdated: "8 hours ago"),
  LeaderboardEntry(
    profilePictureURL: URL(string: "https://picsum.photos/50/50")!,
    firstName: "Jamie", stepsLastWeek: 87500, lastUpdated: "9 hours ago"),
]

#Preview {
  Leaderboard()
}
