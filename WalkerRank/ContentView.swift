import SwiftData
import SwiftUI

struct ContentView: View {
  @StateObject private var healthStore = HealthStore()

  var body: some View {
    VStack {
      Text("Today's Step Count")
        .font(.headline)
      Text("\(Int(healthStore.stepCount))")
        .font(.largeTitle)
        .fontWeight(.bold)

      Button("Refresh") {
        healthStore.fetchSteps()
      }
      .padding()
      .background(Color.blue)
      .foregroundColor(.white)
      .cornerRadius(10)
    }
    .task {
      let authorized = await healthStore.requestAuthorization()
      if authorized {
        healthStore.startObservingStepCount()
      }
    }
  }
}
