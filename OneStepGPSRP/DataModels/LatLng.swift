//
//  LatLng.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//
import Foundation

// MARK: - LatLng
/// LatLng - Geographic coordinates with latitude and longitude.
struct LatLng: Codable {
    let lat: Double?
    let lng: Double?
}
