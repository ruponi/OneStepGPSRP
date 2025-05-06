//
//  APIConfig.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 5/5/25.
//
import Foundation

/// Holds your API‐key and baseURL (you can swap baseURL per build configuration)
struct APIConfig {
    /// Add API key here
    static let apiKey = ""
    static let baseURL = URL(string: "https://track.onestepgps.com/v3/api/public")!
}
