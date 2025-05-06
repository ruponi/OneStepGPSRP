//
//  DeviceState.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//

import Foundation
// MARK: - DeviceState
/// DeviceState - Represents current or past driving state of the device.
struct DeviceState: Codable {
    let driveStatus: String?
    let driveStatusId: String?
    let driveStatusDuration: ValueUnitDisplay?
    let driveStatusDistance: ValueUnitDisplay?
    let driveStatusLatLngDistance: ValueUnitDisplay?
    let driveStatusBeginTime: Date?
    let bestDistanceDelta: ValueUnitDisplay?
    let isNewDriveStatus: Bool?
    let adjustedLatLng: LatLng?
    let beyondMaxDriftDistance: Bool?
    let prevDriveStatusDuration: ValueUnitDisplay?
    let prevDriveStatusDistance: ValueUnitDisplay?
    let prevDriveStatusLatLngDistance: ValueUnitDisplay?
    let prevDriveStatusBeginTime: Date?
    let prevAdjustedLatLng: LatLng?
    let inaccuratePerDeviceSettings: Bool?
    let fuelPercent: Double?
    let softwareOdometer: ValueUnitDisplay?
    let lastSoftwareOdometerReadingTime: Date?
    let odometer: ValueUnitDisplay?
    let vin: String?
    let isVinFromDevicePoint: Bool?
    let counterList: [Counter]?
}
