//
//  DevicePointDetail.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//
import Foundation

// MARK: - DevicePointDetail
/// DevicePointDetail - Detailed telemetry and diagnostic data associated with a device point.
struct DevicePointDetail: Codable {
    let factoryId: String?
    let transmitTime: Date?
    let gpsTime: Date?
    let acc: Bool?
    let latLng: LatLng
    let altitude: ValueUnitDisplay?
    let speed: ValueUnitDisplay?
    let heading: Int?
    let hdop: Double?
    let numSatellites: Int?
    let remoteAddr: String?
    let heventList: [Event]?
    let dtcList: [String]?
    let motionLog: MotionLog?
    let packetSequenceId: String?
    let rssi: Double?
    let tripDistance: ValueUnitDisplay?
    let travelDistance: ValueUnitDisplay?
    let externalVolt: Double?
    let backupBatteryVolt: Double?
    let videoOriginalEvent: Event?
    // Many optional sensor values are omitted here for brevity but should be added as needed
}
