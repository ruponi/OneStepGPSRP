//
//  ValueUnitDisplay.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//
import Foundation
// MARK: - ValueUnitDisplay
/// ValueUnitDisplay - Represents a numerical value with its unit and formatted display.
struct ValueUnitDisplay: Codable {
    let value: Double?
    let unit: String?
    let display: String?
}
