import WidgetKit
import SwiftUI
import ActivityKit

struct MarathonWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MarathonAttributes.self) { context in
            // Lock Screen UI
            VStack {
                Text("Runner: \(context.attributes.runnerID)")
                Text("Position: \(context.state.currentPosition, specifier: "%.1f") / \(context.state.totalDistance) km")
                Text("ETA: \(context.state.estimatedFinishTime, style: .time)")
            }
            .activityBackgroundTint(Color.blue)
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Text("Position: \(context.state.currentPosition, specifier: "%.1f") km")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("ETA: \(context.state.estimatedFinishTime, style: .time)")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Tracking \(context.attributes.runnerID)")
                }
            } compactLeading: {
                Text("Pos \(context.state.currentPosition, specifier: "%.1f") km")
            } compactTrailing: {
                Text(context.state.estimatedFinishTime, style: .time)
            } minimal: {
                Text("\(context.state.currentPosition, specifier: "%.1f") km")
            }
            .widgetURL(URL(string: "yourapp://marathon/\(context.attributes.runnerID)"))
            .keylineTint(Color.red)
        }
    }
}
