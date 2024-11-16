//
//  MarathonAttributes.swift
//  Runner
//
//  Created by asimsharf on 16/11/2024.
//


import ActivityKit
import Foundation

struct MarathonAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var runnerName: String
        var currentPosition: Double
        var totalDistance: Double
        var estimatedFinishTime: Date
    }

    var runnerID: String
}
