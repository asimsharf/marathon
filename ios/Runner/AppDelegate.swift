import Flutter
import UIKit
import ActivityKit
import SwiftUI

@available(iOS 16.1, *)
@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private var channelHandler: ChannelHandler?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        if let controller = window?.rootViewController as? FlutterViewController {
            channelHandler = ChannelHandler(controller: controller)
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
