import Foundation
import HealthKit

@MainActor
class HealthStore: ObservableObject {
  let healthStore = HKHealthStore()
  @Published var stepCount: Double = 0

  func fetchSteps() {
    guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
    else {
      return
    }

    let startOfDay = Calendar.current.startOfDay(for: Date())
    let predicate = HKQuery.predicateForSamples(
      withStart: startOfDay,
      end: Date(),
      options: .strictStartDate
    )

    let query = HKStatisticsCollectionQuery(
      quantityType: stepType,
      quantitySamplePredicate: predicate,
      options: .cumulativeSum,
      anchorDate: startOfDay,
      intervalComponents: DateComponents(day: 1)
    )

    query.initialResultsHandler = { [weak self] query, results, error in
      guard let self = self,
        let stats = results?.statistics().first
      else {
        return
      }

      let summedSteps =
        stats.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
      DispatchQueue.main.async {
        self.stepCount = summedSteps
      }

    }

    healthStore.execute(query)
  }

  func startObservingStepCount() {
    guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
    else {
      return
    }

    let query = HKObserverQuery(sampleType: stepType, predicate: nil) {
      [weak self] _, _, error in
      if let error = error {
        print("Error observing step count: \(error.localizedDescription)")
        return
      }
      self?.fetchSteps()
    }

    healthStore.execute(query)

    healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) {
      success, error in
      if let error = error {
        print(
          "Failed to enable background delivery: \(error.localizedDescription)")
      }
    }

    fetchSteps()
  }

}
