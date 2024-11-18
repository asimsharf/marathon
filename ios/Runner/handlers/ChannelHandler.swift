//
//  ChannelHandler.swift
//  Runner
//
//  Created by asimsharf on 17/11/2024.
//


import Flutter
import UIKit

@available(iOS 16.1, *)
class ChannelHandler {
    
    private let channel: FlutterMethodChannel
    private let activityService = ActivityService()
    
    init(controller: FlutterViewController) {
        channel = FlutterMethodChannel(
            name: "com.sudagoarth.marathon/widgetKit",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            self?.handleMethodCall(call: call, result: result)
        }
    }
    
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startLiveActivity":
            activityService.startLiveActivity(result: result)
        case "stopLiveActivity":
            activityService.stopLiveActivity(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
