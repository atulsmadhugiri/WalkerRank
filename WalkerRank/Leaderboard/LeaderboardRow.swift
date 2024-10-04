import SwiftUI

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
              .font(.caption)
              .fontWeight(.black)
              .fontDesign(.rounded)
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
    .padding(.vertical, 4)
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

#Preview {
  LeaderboardRow(
    position: 1,
    entry: LeaderboardEntry(
      profilePictureURL: URL(string: "https://blob.sh/atul.png")!,
      firstName: "Atul",
      stepsLastWeek: 7600,
      lastUpdated: "one hour ago"
    )
  ).padding()
}
