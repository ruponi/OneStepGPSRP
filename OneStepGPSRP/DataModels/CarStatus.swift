//
//  CarStatus.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 5/5/25.
//
import UIKit
import SwiftUI

/// CarStatus represents the various operational states of a vehicle and provides computed properties:
///   • iconName: SF Symbol name for the status
///   • statusColor: UIColor representing the status
///   • statusTitle: Human-readable title for the status
///   • uiImage: Convenience UIImage for UIKit
///   • image: Convenience SwiftUI Image
///
/// - stopped: The vehicle is at rest and not currently moving.
/// - moving: The vehicle is in motion.
/// - paused: The vehicle movement is temporarily paused (e.g., engine idling).
/// - offLine: The vehicle is unreachable or not transmitting data.
/// - none: No status information is available.
enum CarStatus {
    case stopped    /// Vehicle is not moving.
    case moving     /// Vehicle is currently in motion.
    case paused     /// Vehicle is paused or idling.
    case offLine    /// Vehicle is offline or unreachable.
    case none       /// No status information.
}

extension CarStatus {
    
    /// Returns the SF Symbol name for this status.
    var iconName: String {
        switch self {
        case .stopped:
            return "stop.fill"
        case .moving:
            return "arrowshape.left"
        case .paused:
            return "pause.fill"
        case .offLine:
            return "wifi.slash"
        case .none:
            return "questionmark.circle" // ❓
        }
    }
    
    /// Returns the Color for this status
    var statusColor: UIColor {
        switch self {
        case .stopped:
            return .systemRed
        case .moving:
            return .systemGreen
        case .paused:
            return .systemOrange
        case .offLine:
            return .systemGray
        case .none:
            return .systemGray
        }
    }
    
    /// Returns the Title for this status
    var statusTitle: String {
        switch self {
        case .stopped:
            return "Stopped"
        case .moving:
            return "Driving"
        case .paused:
            return "Waiting"
        case .offLine:
            return "OffLine"
        case .none:
            return ""
        }
    }
    
    /// Convenience UIImage for UIKit usage.
    var uiImage: UIImage? {
        UIImage(systemName: iconName)
    }
    
    /// Convenience SwiftUI Image.
    var image: Image {
        Image(systemName: iconName)
    }
}
