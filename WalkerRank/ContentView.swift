import HealthKitUI
import SwiftData
import SwiftUI

struct ContentView: View {
  @StateObject private var healthStore = HealthStore()

  @State var healthDataAuthenticated = false
  @State var triggerHealthDataPrompt = false

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
      .onAppear {
        if HKHealthStore.isHealthDataAvailable() {
          triggerHealthDataPrompt.toggle()
        }
      }.healthDataAccessRequest(
        store: healthStore.healthStore,
        shareTypes: [],
        readTypes: [HKQuantityType(.stepCount)],
        trigger: triggerHealthDataPrompt
      ) { result in
        switch result {
        case .success(_):
          healthDataAuthenticated = true
          Task {
            await healthStore.startObservingStepCount()
          }
        case .failure(let error):
          fatalError(
            "An error occurred while requesting authentication: \(error)")
        }
      }
    }
  }
}
