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
