import HealthKit

class HealthManager {
    private let healthStore = HKHealthStore()

    /// Requests authorization to read HealthKit data.
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let readTypes: Set = [stepCountType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }
    
    /// Enables background delivery for step count updates.
    func enableBackgroundDeliveryForSteps() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!

        healthStore.enableBackgroundDelivery(for: stepType, frequency: .hourly) { success, error in
            if success {
                print("Background delivery enabled for steps")
            } else if let error = error {
                print("Failed to enable background delivery: \(error.localizedDescription)")
            }
        }
    }
    
    /// Starts observing changes to step count data.
    func startObservingStepChanges() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!

        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Error observing step changes: \(error.localizedDescription)")
                completionHandler()
                return
            }
            
            // Fetch the latest step count and notify the app
            self?.fetchTodaySteps { steps in
                guard let steps = steps else { return }
                print("Steps updated: \(steps)")
                
                // Conditionally call ActivityService if the iOS version is 16.1 or newer
                 if #available(iOS 16.1, *) {
                     ActivityService.shared.updateLiveActivityWithSteps(steps: steps)
                 }
                completionHandler()
            }
        }

        healthStore.execute(query)
    }

    /// Fetches today's step count from HealthKit.
    func fetchTodaySteps(completion: @escaping (Double?) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch steps data: \(error?.localizedDescription ?? "N/A")")
                completion(nil)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        healthStore.execute(query)
    }
}
