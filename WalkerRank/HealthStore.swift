import Foundation
import HealthKit

class HealthStore: ObservableObject {
  private let healthStore = HKHealthStore()

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

  private func fetchSteps() {
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

    let query = HKStatisticsQuery(
      quantityType: stepType,
      quantitySamplePredicate: predicate,
      options: .cumulativeSum
    ) { [weak self] _, result, error in
      guard let self = self else { return }

      if let error = error {
        print("Failed to fetch steps with error: \(error.localizedDescription)")
        return
      }

      DispatchQueue.main.async {
        self.stepCount =
          result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
      }
    }

    healthStore.execute(query)
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
