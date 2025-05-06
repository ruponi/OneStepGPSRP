//
//  Event.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//

import Foundation

// MARK: - Event
/// Event - Represents a logged event related to the device (e.g., engine_off).
struct Event: Codable {
    let heventType: String?

    enum CodingKeys: String, CodingKey {
        case heventType = "hevent_type"
    }
}
