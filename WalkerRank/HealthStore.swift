import Foundation
import HealthKit

@MainActor
class HealthStore: ObservableObject {
  let healthStore = HKHealthStore()
  @Published var stepCount: Double = 0

  func requestAuthorization() async -> Bool {
    guard HKHealthStore.isHealthDataAvailable() else {
      return false
    }

    guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
    else {
      return false
    }

    do {
      try await healthStore.requestAuthorization(toShare: [], read: [stepType])
      return true
    } catch {
      print("Failed to request authorization: \(error.localizedDescription)")
      return false
    }
  }

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

extension HKHealthStore {
  func executeStatisticsQuery(
    quantityType: HKQuantityType, predicate: NSPredicate
  ) async throws -> HKStatistics {
    try await withCheckedThrowingContinuation { continuation in
      let query = HKStatisticsQuery(
        quantityType: quantityType,
        quantitySamplePredicate: predicate,
        options: .cumulativeSum
      ) { _, result, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else if let result = result {
          continuation.resume(returning: result)
        } else {
          continuation.resume(
            throwing: NSError(
              domain: "HealthStore", code: 0,
              userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
        }
      }
      self.execute(query)
    }
  }
}
