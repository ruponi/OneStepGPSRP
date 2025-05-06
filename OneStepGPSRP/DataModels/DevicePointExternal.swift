//
//  DevicePointExternal.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//

import Foundation
// MARK: - DevicePointExternal
/// DevicePointExternal - Contains calculated or external values associated with a device point.
struct DevicePointExternal: Codable {
    let postedSpeedLimit: [String: Double]?
    let softwareOdometerReading: [String: Double]?
    let hardwareOdometerOffset: [String: Double]?
    let stuckOdometerOffset: [String: Double]?
}
