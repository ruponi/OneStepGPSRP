//
//  Counter.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//

import Foundation
// MARK: - Counter
/// Counter - Tracks named time-based counters (e.g., engine hours).
struct Counter: Codable {
    let key: String
    let val: Double
    let offset: Double
}
