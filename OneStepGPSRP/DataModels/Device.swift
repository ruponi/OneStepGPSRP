//
//  Device.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//
import Foundation
import UIKit
import SwiftUI

/// Device - Represents a GPS tracking device with its settings, telemetry and ownership info.
struct Device: Codable {
    let deviceId: String
    let createdAt: Date
    let updatedAt: Date
    let activatedAt: Date?
    let deliveredAt: Date?
    let factoryId: String
    let activeState: String
    let displayName: String
    let make: String
    let model: String
    let connData: ConnData
    let settings: Settings?
    let userIdList: [String]
    let online: Bool
    let latestDevicePoint: DevicePoint?
    let latestAccurateDevicePoint: DevicePoint?
    
    /// Return Calculated duration of  latest drive status in format Days Hours Mins
    func latestStatusDuration() -> String {
        return latestAccurateDevicePoint?.deviceState?.driveStatusBeginTime?.timeToCurrentDateDHMS() ?? "-"
    }
    
    /// Return curent Device / Car status
    func getCarStatus() -> CarStatus {
        
        if !online {return .offLine}
        
        guard let status = latestAccurateDevicePoint?.deviceState?.driveStatus else {
            return .stopped
        }
        switch status {
        case "off":
            return .stopped
        case "driving":
            let spd = self.latestDevicePoint?.speed ?? 0
            if spd == 0 {
                return .paused
            } else {
                return .moving
            }
        case "idle":
            return .paused
        default:
            return  .none
        }
    }
}
