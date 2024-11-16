import WidgetKit
import SwiftUI
import Intents

struct MarathonProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct MarathonWidgetEntryView : View {
    var entry: MarathonProvider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

struct MarathonWidget: Widget {
    let kind: String = "MarathonWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MarathonProvider()) { entry in
            MarathonWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Marathon Widget")
        .description("Track your marathon progress.")
    }
}
