import ActivityKit
import Foundation
import HealthKit

@available(iOS 16.1, *)
class ActivityService {
    
    static let shared = ActivityService() // Singleton instance
    private var marathonActivity: Activity<MarathonAttributes>?
    private let healthManager = HealthManager()
    private var updateTimer: Timer?
    
    /// Starts a new Live Activity using step data from HealthKit.
    func startLiveActivity(result: @escaping FlutterResult) {
        // Request HealthKit authorization
        healthManager.requestAuthorization { success, error in
            guard success else {
                result(FlutterError(code: "AUTH_ERROR", message: "HealthKit authorization failed", details: error?.localizedDescription))
                return
            }
            
            // Enable background delivery and start observing step changes
            self.healthManager.enableBackgroundDeliveryForSteps()
            self.healthManager.startObservingStepChanges()
            
            // Fetch initial step count
            self.healthManager.fetchTodaySteps { steps in
                guard let steps = steps else {
                    result(FlutterError(code: "DATA_ERROR", message: "Failed to fetch HealthKit data", details: nil))
                    return
                }
                
                let currentPosition = steps / 1300.0 // Approximate steps-to-km conversion
                let futureFinishTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
                
                let initialContentState = MarathonAttributes.ContentState(
                    runnerName: "John Doe",
                    currentPosition: currentPosition,
                    totalDistance: 42.2,
                    estimatedFinishTime: futureFinishTime
                )
                
                let activityAttributes = MarathonAttributes(runnerID: "runner_123")
                
                do {
                    self.marathonActivity = try Activity.request(
                        attributes: activityAttributes,
                        contentState: initialContentState
                    )
                    result("Started marathon Live Activity with ID: \(self.marathonActivity?.id ?? "N/A")")
                    self.startPeriodicUpdates() // Start periodic updates
                } catch let error {
                    result(FlutterError(code: "START_ERROR", message: "Error starting marathon Live Activity", details: error.localizedDescription))
                }
            }
        }
    }
    
    /// Updates the existing Live Activity with new data.
    func updateLiveActivityWithSteps(steps: Double) {
        guard let marathonActivity = marathonActivity else { return }
        
        let updatedContentState = MarathonAttributes.ContentState(
            runnerName: "John Doe",
            currentPosition: steps / 1300.0, // Approximate conversion
            totalDistance: 42.2,
            estimatedFinishTime: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        )
        
        Task {
            do {
                try await marathonActivity.update(using: updatedContentState)
                print("Updated marathon Live Activity with steps: \(steps)")
            } catch {
                print("Failed to update marathon Live Activity")
            }
        }
    }
    
    /// Starts periodic updates every 10 minutes when the app is in the foreground.
    private func startPeriodicUpdates() {
        updateTimer?.invalidate() // Invalidate any existing timer
        updateTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { [weak self] _ in
            self?.healthManager.fetchTodaySteps { steps in
                guard let steps = steps else { return }
                self?.updateLiveActivityWithSteps(steps: steps)
            }
        }
    }
    
    /// Stops the Live Activity and cancels periodic updates.
    func stopLiveActivity(result: @escaping FlutterResult) {
        guard let marathonActivity = marathonActivity else {
            result(FlutterError(code: "STOP_ERROR", message: "No active marathon Live Activity to stop", details: nil))
            return
        }
        
        let finalContentState = MarathonAttributes.ContentState(
            runnerName: "John Doe",
            currentPosition: 42.2,
            totalDistance: 42.2,
            estimatedFinishTime: Date()
        )
        
        Task {
            do {
                try await marathonActivity.end(using: finalContentState, dismissalPolicy: .default)
                result("Stopped marathon Live Activity")
                self.marathonActivity = nil
                updateTimer?.invalidate() // Stop the timer
                updateTimer = nil
            } catch {
                result(FlutterError(code: "STOP_ERROR", message: "Failed to stop marathon Live Activity", details: error.localizedDescription))
            }
        }
    }
}
