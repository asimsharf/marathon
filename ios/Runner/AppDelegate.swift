import Flutter
import UIKit
import ActivityKit
import SwiftUI

@available(iOS 16.1, *)
@main
@objc class AppDelegate: FlutterAppDelegate {
    
    var marathonActivity: Activity<MarathonAttributes>?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        if let controller = window?.rootViewController as? FlutterViewController {
            
            let channel = FlutterMethodChannel(
                name: "com.sudagoarth.marathon/widgetKit",
                binaryMessenger: controller.binaryMessenger
            )
            
            channel.setMethodCallHandler(
                { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                    switch call.method {
                    case "startLiveActivity":
                        self?.startLiveActivity(result: result)
                    case "updateLiveActivity":
                        self?.updateLiveActivity(result: result)
                    case "stopLiveActivity":
                        self?.stopLiveActivity(result: result)
                    case "showAll":
                        self?.showAllLiveActivity(result: result)
                    default:
                        result(FlutterMethodNotImplemented)
                    }
                }
            )
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func startLiveActivity(result: @escaping FlutterResult) {
        let futureFinishTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let dateRange = Date.now...futureFinishTime
        
        let initialContentState = MarathonAttributes.ContentState(
            runnerName: "John Doe",
            currentPosition: 5.0,
            totalDistance: 42.2,
            estimatedFinishTime: futureFinishTime
        )
        
        let activityAttributes = MarathonAttributes(
            runnerID: "runner_123"
        )
        
        do {
            marathonActivity = try Activity.request(
                attributes: activityAttributes,
                contentState: initialContentState
            )
            result("Started marathon Live Activity with ID: \(marathonActivity?.id ?? "N/A")")
        } catch (let error) {
            result(FlutterError(code: "START_ERROR", message: "Error starting marathon Live Activity", details: error.localizedDescription))
        }
    }
    
    func updateLiveActivity(result: @escaping FlutterResult) {
        guard let marathonActivity = marathonActivity else {
            result(FlutterError(code: "UPDATE_ERROR", message: "No active marathon Live Activity to update", details: nil))
            return
        }
        
        let updatedPosition = 21.1 // Example updated position halfway through the marathon
        let updatedFinishTime = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        
        let updatedContentState = MarathonAttributes.ContentState(
            runnerName: "John Doe",
            currentPosition: updatedPosition,
            totalDistance: 42.2,
            estimatedFinishTime: updatedFinishTime
        )
        
        let alertConfiguration = AlertConfiguration(
            title: "Marathon Update",
            body: "The runner is halfway through the marathon!",
            sound: .default
        )
        
        Task {
            await marathonActivity.update(using: updatedContentState, alertConfiguration: alertConfiguration)
            result("Updated marathon Live Activity")
        }
    }
    
    func stopLiveActivity(result: @escaping FlutterResult) {
        guard let marathonActivity = marathonActivity else {
            result(FlutterError(code: "STOP_ERROR", message: "No active marathon Live Activity to stop", details: nil))
            return
        }
        
        let finalPosition = 42.2 // Example final position marking marathon completion
        let finalContentState = MarathonAttributes.ContentState(
            runnerName: "John Doe",
            currentPosition: finalPosition,
            totalDistance: 42.2,
            estimatedFinishTime: Date()
        )
        
        Task {
            await marathonActivity.end(using: finalContentState, dismissalPolicy: .default)
            result("Stopped marathon Live Activity")
        }
    }
    
    func showAllLiveActivity(result: @escaping FlutterResult) {
        Task {
            var activityDetails: [String] = []
            for await activity in Activity<MarathonAttributes>.activityUpdates {
                activityDetails.append("Marathon details: \(activity.attributes)")
            }
            result(activityDetails.joined(separator: "\n"))
        }
    }
}
