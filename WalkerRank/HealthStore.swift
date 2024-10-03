import Foundation
import HealthKit

class HealthStore {
  private let healthStore = HKHealthStore()

  func requestAuthorization(completion: @escaping (Bool) -> Void) {
    guard HKHealthStore.isHealthDataAvailable() else {
      completion(false)
      return
    }

    guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
    else {
      completion(false)
      return
    }

    healthStore.requestAuthorization(
      toShare: [],
      read: [stepType]
    ) {
      success, error in
      completion(success)
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
