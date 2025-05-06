//
//  DeviceCalloutView.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 5/4/25.
//

import SwiftUI
import CoreLocation

/// SwiftUI view for annotation callout, with full info.
struct DeviceCalloutView: View {
    let device: Device
    @State private var address: String = "Loading..."
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: name and status
            HStack {
                Text(device.displayName)
                    .font(.headline)
                Spacer()
                
                Text(device.getCarStatus().statusTitle + " " + device.latestStatusDuration())
                    .font(.caption2)
                    .padding(6)
                    .background(Color(uiColor: device.getCarStatus().statusColor))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            Divider()
            
            // Body columns
            HStack(alignment: .top) {
                // Left column
                VStack(alignment: .leading, spacing: 4) {
                    Text("LOCATION")
                        .font(.caption).bold()
                    Text(address)
                        .font(.caption)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    
                    Text("ODOMETER")
                        .font(.caption).bold()
                    Text(device.latestAccurateDevicePoint?.deviceState?.odometer?.display ?? "—")
                        .font(.caption)
                    
                    Text("ENGINE HOURS")
                        .font(.caption).bold()
                    if let hours = device.latestAccurateDevicePoint?.deviceState?.counterList?.first(where: { $0.key == "eh" })?.val {
                        Text(String(format: "%.2f", hours))
                            .font(.caption)
                    }
                }
                Spacer()
                // Right column
                VStack(alignment: .leading, spacing: 4) {
                    Text("ARRIVED")
                        .font(.caption).bold()
                    //device.latestDevicePoint?.dtServer
                    if let date = device.latestAccurateDevicePoint?.deviceState?.driveStatusBeginTime {
                        Text(date, style: .date)
                            .font(.caption)
                        Text(date, style: .time)
                            .font(.caption)
                    }
                    Text("ASSIGNMENT")
                        .font(.caption).bold()
                    Text("No assignments")
                        .font(.caption)
                    Text("DEVICE GROUPS")
                        .font(.caption).bold()
                    Text("No group")
                        .font(.caption)
                }
            }
        }
        .padding(12)
        .frame(width: 280)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.clear)))
        .onAppear {
            fetchAddress()
        }
    }
    
    private func fetchAddress() {
        // 1. Grab the latest coordinate
        guard let pt = device.latestAccurateDevicePoint else {
            address = "Unknown location"
            return
        }
        let loc = CLLocation(latitude: pt.lat ?? 0, longitude: pt.lng ?? 0)
        
        // 2. Reverse‐geocode it
        CLGeocoder().reverseGeocodeLocation(loc) { placemarks, error in
            if let placemark = placemarks?.first {
                // Build a single line from available fields
                let parts = [
                    placemark.name,
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.postalCode
                ].compactMap { $0 }
                address = parts.joined(separator: ", ")
            }
            else if let err = error {
                address = "Error: \(err.localizedDescription)"
            }
            else {
                address = "No address found"
            }
        }
    }
}
    
