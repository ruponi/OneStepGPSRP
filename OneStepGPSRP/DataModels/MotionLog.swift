//
//  MotionLog.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//

import Foundation
// MARK: - MotionLog
/// MotionLog - Captures motion analysis data such as start/end headings and max forces.
struct MotionLog: Codable {
    let startTime: Date?
    let endTime: Date?
    let startHeading: Int?
    let endHeading: Int?
    let maxAcceleratingForce: ValueUnitDisplay?
    let maxDeceleratingForce: ValueUnitDisplay?
    let maxRightTurnForce: ValueUnitDisplay?
    let maxLeftTurnForce: ValueUnitDisplay?
}
