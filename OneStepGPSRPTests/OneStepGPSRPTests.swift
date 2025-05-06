//
//  OneStepGPSRPTests.swift
//  OneStepGPSRPTests
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//

import XCTest
@testable import OneStepGPSRP
import Combine

/// Mock success service
private struct MockSuccessService: DeviceServiceProtocol {
    let toReturn: [Device]
    func fetchDevices(latestPoint: Bool) async throws -> [Device] {
        return toReturn
    }
}

/// Mock failure service
private struct MockFailureService: DeviceServiceProtocol {
    enum Err: Error, LocalizedError { case fail
        var errorDescription: String? { "Network error" }
    }
    func fetchDevices(latestPoint: Bool) async throws -> [Device] {
        throw Err.fail
    }
}

@MainActor
final class DeviceMapModelTests: XCTestCase {
    /// Test that a successful load populates `devices` and clears errors.
    func testLoadDevicesSuccess() async {
        // Arrange
        let now = Date()
        let dummy = Device(
            deviceId: "x", createdAt: now, updatedAt: now,
            activatedAt: nil, deliveredAt: nil, factoryId: "",
            activeState: "", displayName: "",
            make: "", model: "",
            connData: ConnData(calampNextLookupTime: nil, calampIprOmegaFeePaid: false, isOnCtc: false),
            settings: nil, userIdList: [], online: true,
            latestDevicePoint: nil, latestAccurateDevicePoint: nil
        )
        let vm = DeviceMapModel(service: MockSuccessService(toReturn: [dummy]))
        
        // Act
        await vm.loadDevices(latestPoint: true)
        
        // Assert
        XCTAssertEqual(vm.devices.count, 1)
        XCTAssertNil(vm.errorMessage)
    }
    
    /// Test that a failed load sets `errorMessage` and leaves `devices` unchanged.
    func testLoadDevicesFailure() async {
        // Arrange
        let vm = DeviceMapModel(service: MockFailureService())
        vm.devices = [ /* preloaded device */ ]
        
        // Act
        await vm.loadDevices(latestPoint: false)
        
        // Assert
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.devices.isEmpty, "Devices array should be cleared on failure")
    }
}
