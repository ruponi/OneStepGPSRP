//
//  Settings.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//

import Foundation

/// Settings - Configuration and thresholds used to control how a device behaves and reports data.
struct Settings: Codable {
    let beginMovingSpeed: UnitValue
    let beginStoppedSpeed: UnitValue
    let maxDriftDistance: UnitValue
    let minNumSatellites: Int
    let ignoreUnsetMinNumSats: Bool?
    let maxHdop: Double?
    let driveTimeout: UnitValue
    let stopTimeout: UnitValue
    let offlineTimeout: UnitValue
    let historyCalcDuration: UnitValue
    let fuelConsumption: FuelConsumption
    let engineHoursCounterConfig: String
    let useV3EngineHours: Bool
    let historyRetentionDays: Int
    let harshEventMinSpeed: UnitValue
    let speedSourcesTrusted: [String]?
}

/// UnitValue - A simple structure representing a value with unit and display string.
struct UnitValue: Codable {
    let value: Double?
    let unit: String?
    let display: String?
}

/// FuelConsumption - Represents how fuel usage is configured and calculated.
struct FuelConsumption: Codable {
    let calculationMethod: String
    let measurement: String
    let fuelType: String
    let fuelCost: Double?
    let fuelEconomy: Double
}
