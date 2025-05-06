//
//  Untitled.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 5/4/25.
//

import SwiftUI
import Foundation



/// A SwiftUI list view displaying devices with search, sort, visibility, and row selection to focus on map.
struct DeviceListView: View {
    /// Devices to display
    let devices: [Device]
    /// Callback when a device is tapped
    let onSelect: (Device) -> Void

    // MARK: - Search & Sort
    @State private var searchText = ""
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Name", 
             status = "Status",
             lastUpdated = "Last Updated",
             speed = "Speed"
        var id: Self { self }
    }
    
    @AppStorage(StorageKeys.sortOption) private var sortRawValue: String = SortOption.name.rawValue
    private var sortOption: SortOption {
        get { SortOption(rawValue: sortRawValue) ?? .name }
        set { sortRawValue = newValue.rawValue }
    }

    // MARK: - Visibility
    @AppStorage(StorageKeys.hiddenIDs) private var hiddenIDsData: Data = Data()
    @State private var hiddenIDs: Set<String> = []
    @Environment(\.presentationMode) private var presentation
    
  

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header with counts
            let total = filteredDevices.count
            let hiddenCount = filteredDevices.filter { hiddenIDs.contains($0.deviceId) }.count
            Text("Showing \(total - hiddenCount) of \(total) devices (\(hiddenCount) hidden)")
                .font(.caption2)
                .padding(.vertical, 4)

            List(filteredDevices) { device in
                            HStack {
           
                            // Visibility toggle
                            Button {
                                if hiddenIDs.contains(device.deviceId) {
                                    hiddenIDs.remove(device.deviceId)
                                } else {
                                    hiddenIDs.insert(device.deviceId)
                                }
                                saveHiddenIDs()
                            } label: {
                                Image(systemName: hiddenIDs.contains(device.deviceId) ? "eye.slash" : "eye")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())

                            // Device info
                            VStack(alignment: .leading, spacing: 2) {
                                Text(device.displayName).font(.headline)
                                Text(device.deviceId).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(device.getCarStatus().statusTitle).font(.subheadline)
                                if let dt = device.latestDevicePoint?.dtServer {
                                    Text(dt, style: .time).font(.caption2).foregroundColor(.secondary)
                                }
                                if let spd = device.latestDevicePoint?.speed {
                                    Text(String(format: "%.0f km/h", spd))
                                        .font(.caption2).foregroundColor(.secondary)
                                }
                            }
                        }
                            .contentShape(Rectangle()) // make entire row tappable
                                           .onTapGesture {
                                               presentation.wrappedValue.dismiss()
                                               onSelect(device)
                                           }
                        .opacity(hiddenIDs.contains(device.deviceId) ? 0.4 : 1.0)
                 
                }
            .listStyle(PlainListStyle())
            .searchable(text: $searchText, prompt: "Search by name or ID")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort by", selection: $sortRawValue) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option.rawValue)
                            }
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text(sortOption.rawValue).font(.caption2)
                        }
                    }
                }
            }
            .onAppear { loadHiddenIDs() }
        }
        .navigationTitle("Devices")
    }
}

//MARK: - extension for DeviceListView with some helpers
extension DeviceListView {
    private func loadHiddenIDs() {
        if let arr = try? JSONDecoder().decode([String].self, from: hiddenIDsData) {
            hiddenIDs = Set(arr)
        }
    }
    
    private func saveHiddenIDs() {
        if let data = try? JSONEncoder().encode(Array(hiddenIDs)) {
            hiddenIDsData = data
        }
    }

    // MARK: - Filtered & Sorted
    private var filteredDevices: [Device] {
        let filtered = devices.filter { device in
            searchText.isEmpty || device.displayName.localizedCaseInsensitiveContains(searchText) || device.deviceId.localizedCaseInsensitiveContains(searchText)
        }
        // Sort according to selected option
        switch sortOption {
        case .name:
            return filtered.sorted { $0.displayName < $1.displayName }
        case .status:
            // Offline < Stopped < Waiting < Moving
            return filtered.sorted { $0.getCarStatus().priority > $1.getCarStatus().priority }
        case .lastUpdated:
            return filtered.sorted {
                ($0.latestDevicePoint?.dtServer ?? Date.distantPast) > ($1.latestDevicePoint?.dtServer ?? Date.distantPast)
            }
        case .speed:
            return filtered.sorted {
                ($0.latestDevicePoint?.speed ?? 0) > ($1.latestDevicePoint?.speed ?? 0)
            }
        }
    }
}


extension CarStatus {
    /// Sort priority: higher values sort earlier.
    var priority: Int {
        switch self {
        case .none:   return -1
        case .offLine:return  0
        case .stopped:return  1
        case .paused: return  2
        case .moving: return  3
        }
    }
}
/*

/// List view presenting devices with search and sort functionality.
struct DeviceListView: View {
    let devices: [Device]
    @State private var searchText = ""
    
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Name"
        case status = "Status"
        case lastUpdated = "Last Updated"
        case speed = "Speed"
        
        var id: Self { self }
    }
    
    @State private var sortOption: SortOption = .name
    
    /// Filters and sorts devices based on search text and selected sort option
    private var filteredDevices: [Device] {
        // Filter by name or ID
        let filtered = devices.filter { device in
            searchText.isEmpty || device.displayName.localizedCaseInsensitiveContains(searchText) || device.deviceId.localizedCaseInsensitiveContains(searchText)
        }
        // Sort according to selected option
        switch sortOption {
        case .name:
            return filtered.sorted { $0.displayName < $1.displayName }
        case .status:
            // Offline < Stopped < Waiting < Moving
            func statusRank(_ d: Device) -> Int {
                switch d.getCarStatus() {
                case .offLine: return 0
                case .stopped: return 1
                case .paused: return 2
                case .moving: return 3
                case .none: return -1
                }
            }
            return filtered.sorted { statusRank($0) > statusRank($1) }
        case .lastUpdated:
            return filtered.sorted {
                ($0.latestDevicePoint?.dtServer ?? Date.distantPast) > ($1.latestDevicePoint?.dtServer ?? Date.distantPast)
            }
        case .speed:
            return filtered.sorted {
                ($0.latestDevicePoint?.speed ?? 0) > ($1.latestDevicePoint?.speed ?? 0)
            }
        }
    }
    
    var body: some View {
        List(filteredDevices) { device in
            HStack {
                // Left: Name & ID
                VStack(alignment: .leading, spacing: 4) {
                    Text(device.displayName)
                        .font(.headline)
                    Text(device.deviceId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                // Right: Status, Last Updated, Speed
                VStack(alignment: .trailing, spacing: 4) {
                    // Status
                    let status: String = device.getCarStatus().statusTitle
                    Text(status)
                        .font(.subheadline)
                    // Last updated time
                    Text(device.latestStatusDuration())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    // Current speed
                    if let spd = device.latestDevicePoint?.speed {
                        Text(String(format: "%.0f km/h", spd))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 6)
        }
        .searchable(text: $searchText, prompt: "Search devices by name or ID")
        .navigationTitle("Devices")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
    }
}
*/
