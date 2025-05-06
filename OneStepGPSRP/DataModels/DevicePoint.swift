//
//  DevicePoint.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//
import Foundation

// MARK: - DevicePoint
/// DevicePoint - Represents the most recent location data point for a device.
struct DevicePoint: Codable {
    let devicePointId: String
    let dtServer: Date
    let dtTracker: Date
    let lat: Double?
    let lng: Double?
    let altitude: Double?
    let angle: Int?
    let speed: Double
    let params: [String: String]?
   // let devicePointExternal: DevicePointExternal?
    let devicePointDetail: DevicePointDetail?
    let deviceState: DeviceState?
    let deviceStateStale: Bool?
    let sequence: String
}

