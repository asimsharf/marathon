import WidgetKit
import SwiftUI

@main
struct MarathonWidgetBundle: WidgetBundle {
    var body: some Widget {
        MarathonWidget()
        MarathonWidgetLiveActivity()
    }
}
