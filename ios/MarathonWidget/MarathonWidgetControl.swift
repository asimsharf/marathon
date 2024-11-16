//
//  MarathonWidgetControl.swift
//  MarathonWidget
//
//  Created by asimsharf on 16/11/2024.
//

import AppIntents
import SwiftUI
import WidgetKit
import ActivityKit

struct MarathonWidgetControl: ControlWidget {
    static let kind: String = "com.sudagoarth.marathon.MarathonWidget"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Marathon Tracking",
                isOn: value.isRunning,
                action: StartMarathonIntent(value.runnerID)
            ) { isRunning in
                Label(isRunning ? "Tracking" : "Stopped", systemImage: isRunning ? "figure.run.circle.fill" : "figure.walk.circle")
            }
        }
        .displayName("Marathon Tracker")
        .description("A control widget to start and stop marathon tracking.")
    }
}

extension MarathonWidgetControl {
    struct Value {
        var isRunning: Bool
        var runnerID: String
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: MarathonConfiguration) -> Value {
            MarathonWidgetControl.Value(isRunning: false, runnerID: configuration.runnerID)
        }

        func currentValue(configuration: MarathonConfiguration) async throws -> Value {
            // Check if there is an active marathon activity for the given runnerID
            let isRunning = Activity<MarathonAttributes>.activities.contains { $0.attributes.runnerID == configuration.runnerID }
            return MarathonWidgetControl.Value(isRunning: isRunning, runnerID: configuration.runnerID)
        }
    }
}

// Configuration Intent for Runner ID
struct MarathonConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Marathon Runner Configuration"

    @Parameter(title: "Runner ID", default: "runner_123")
    var runnerID: String
}

// Intent to Start or Stop Marathon Tracking
struct StartMarathonIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start or Stop Marathon Tracking"

    typealias ValueType = Bool  // Ensure ValueType is Bool for ControlWidgetToggle compatibility

    @Parameter(title: "Runner ID")
    var runnerID: String

    @Parameter(title: "Marathon is running")
    var value: Bool  // Required parameter for SetValueIntent to manage the toggle state

    init() {}

    init(_ runnerID: String) {
        self.runnerID = runnerID
        self.value = false
    }

    func perform() async throws -> some IntentResult {
        if value {
            // Start the marathon live activity
            let attributes = MarathonAttributes(runnerID: runnerID)
            let contentState = MarathonAttributes.ContentState(
                runnerName: "John Doe",  // Example name
                currentPosition: 0.0,
                totalDistance: 42.2,
                estimatedFinishTime: Date().addingTimeInterval(3600) // Example ETA
            )
            do {
                _ = try Activity<MarathonAttributes>.request(
                    attributes: attributes,
                    content: .init(state: contentState, staleDate: Date().addingTimeInterval(60)) // Stale date set to 1 minute from now
                )
                print("Started marathon activity for \(runnerID)")
            } catch {
                print("Error starting marathon activity: \(error)")
            }
        } else {
            // Stop the marathon live activity
            if let marathonActivity = Activity<MarathonAttributes>.activities.first(where: { $0.attributes.runnerID == runnerID }) {
                await marathonActivity.end(.none, dismissalPolicy: .immediate)
                print("Stopped marathon activity for \(runnerID)")
            }
        }
        return .result()
    }
}
