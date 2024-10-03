import Foundation
import HealthKit

class HealthStore {
  private let healthStore = HKHealthStore()

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

  func fetchSteps() async -> Double {
    guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
    else {
      return 0
    }

    let startOfDay = Calendar.current.startOfDay(for: Date())
    let predicate = HKQuery.predicateForSamples(
      withStart: startOfDay,
      end: Date(),
      options: .strictStartDate
    )

    do {
      let result = try await healthStore.executeStatisticsQuery(
        quantityType: stepType,
        predicate: predicate
      )
      return result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
    } catch {
      print("Failed to fetch steps with error: \(error.localizedDescription)")
      return 0
    }
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
