import SwiftData
import SwiftUI

struct ContentView: View {
  @StateObject private var healthStore = HealthStore()

  var body: some View {
    VStack {
      Text("Atul's Step Count")
        .font(.headline)
      Text("\(Int(healthStore.stepCount))")
        .font(.largeTitle)
        .fontWeight(.bold)
        .contentTransition(.numericText())

      Button("Refresh", systemImage: "arrow.clockwise.circle.fill") {
        healthStore.fetchSteps()
      }
      .background(Color.blue)
      .foregroundColor(.white)
      .cornerRadius(10)
      .buttonStyle(.bordered)
    }
    .task {
      let authorized = await healthStore.requestAuthorization()
      if authorized {
        healthStore.startObservingStepCount()
      }
    }
  }
}
