//
//  ActivityService.swift
//  Runner
//
//  Created by asimsharf on 17/11/2024.
//

import ActivityKit
import Foundation

@available(iOS 16.1, *)
class ActivityService {
    
    // Current marathon activity instance
    private var marathonActivity: Activity<MarathonAttributes>?
    
    /// Starts a new Live Activity with initial parameters.
    func startLiveActivity(result: @escaping FlutterResult) {
        guard marathonActivity == nil else {
            result(FlutterError(code: "START_ERROR", message: "A marathon Live Activity is already running", details: nil))
            return
        }
        
        let futureFinishTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let initialContentState = createContentState(
            runnerName: "John Doe",
            currentPosition: 5.0,
            estimatedFinishTime: futureFinishTime
        )
        
        let activityAttributes = MarathonAttributes(runnerID: "runner_123")
        
        do {
            marathonActivity = try Activity.request(
                attributes: activityAttributes,
                contentState: initialContentState
            )
            result("Started marathon Live Activity with ID: \(marathonActivity?.id ?? "N/A")")
        } catch let error {
            result(FlutterError(code: "START_ERROR", message: "Error starting marathon Live Activity", details: error.localizedDescription))
        }
    }
    
    /// Updates the existing Live Activity with new data.
    func updateLiveActivity(result: @escaping FlutterResult) {
        guard let marathonActivity = marathonActivity else {
            result(FlutterError(code: "UPDATE_ERROR", message: "No active marathon Live Activity to update", details: nil))
            return
        }
        
        let updatedContentState = createContentState(
            runnerName: "John Doe",
            currentPosition: 21.1,
            estimatedFinishTime: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        )
        
        let alertConfiguration = AlertConfiguration(
            title: "Marathon Update",
            body: "The runner is halfway through the marathon!",
            sound: .default
        )
        
        Task {
            do {
                try await marathonActivity.update(using: updatedContentState, alertConfiguration: alertConfiguration)
                result("Updated marathon Live Activity")
            } catch {
                result(FlutterError(code: "UPDATE_ERROR", message: "Failed to update marathon Live Activity", details: error.localizedDescription))
            }
        }
    }
    
    /// Ends the current Live Activity with final data.
    func stopLiveActivity(result: @escaping FlutterResult) {
        guard let marathonActivity = marathonActivity else {
            result(FlutterError(code: "STOP_ERROR", message: "No active marathon Live Activity to stop", details: nil))
            return
        }
        
        let finalContentState = createContentState(
            runnerName: "John Doe",
            currentPosition: 42.2, // End position for completion
            estimatedFinishTime: Date()
        )
        
        Task {
            do {
                try await marathonActivity.end(using: finalContentState, dismissalPolicy: .default)
                result("Stopped marathon Live Activity")
                self.marathonActivity = nil // Clear the activity
            } catch {
                result(FlutterError(code: "STOP_ERROR", message: "Failed to stop marathon Live Activity", details: error.localizedDescription))
            }
        }
    }
    
    /// Displays all active Live Activities.
    func showAllLiveActivity(result: @escaping FlutterResult) {
        Task {
            var activityDetails: [String] = []
            for await activity in Activity<MarathonAttributes>.activityUpdates {
                activityDetails.append("Marathon details: \(activity.attributes)")
            }
            result(activityDetails.joined(separator: "\n"))
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Creates a new content state for the activity.
    private func createContentState(runnerName: String, currentPosition: Double, estimatedFinishTime: Date) -> MarathonAttributes.ContentState {
        return MarathonAttributes.ContentState(
            runnerName: runnerName,
            currentPosition: currentPosition,
            totalDistance: 42.2,
            estimatedFinishTime: estimatedFinishTime
        )
    }
    
    /// Returns true if there is an active marathon Live Activity.
    private func isMarathonActivityActive() -> Bool {
        return marathonActivity != nil
    }
}
