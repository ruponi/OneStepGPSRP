//
//  ConnData.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//
import Foundation

/// ConnData - Describes connection-related status and flags.
struct ConnData: Codable {
    let calampNextLookupTime: Date?
    let calampIprOmegaFeePaid: Bool
    let isOnCtc: Bool

}
