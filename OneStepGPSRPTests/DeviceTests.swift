//
//  DeviceTests.swift
//  OneStepGPSRPTests
//
//  Created by Ruslan Ponomarenko on 5/5/25.
//

import XCTest
@testable import OneStepGPSRP

/// Tests for the `Device` model’s status & duration logic.
final class DeviceTests: XCTestCase {
    private func makeDevice(
        online: Bool,
        driveStatus: String?,
        speed: Double
    ) -> Device {
        let now = Date()
        let connData = ConnData(
            calampNextLookupTime: nil,
            calampIprOmegaFeePaid: false,
            isOnCtc: false
        )
        let defaultUnitValue = ValueUnitDisplay(value: 0, unit: "", display: "")
        let defaultValue = UnitValue(value: 0, unit: "", display: "")
        let settings = Settings(
            beginMovingSpeed: defaultValue,
            beginStoppedSpeed: defaultValue,
            maxDriftDistance: defaultValue,
            minNumSatellites: 0,
            ignoreUnsetMinNumSats: false,
            maxHdop: 0,
            driveTimeout: defaultValue,
            stopTimeout: defaultValue,
            offlineTimeout: defaultValue,
            historyCalcDuration: defaultValue,
            fuelConsumption: FuelConsumption(
                calculationMethod: "", measurement: "", fuelType: "", fuelCost: 0, fuelEconomy: 0
            ),
            engineHoursCounterConfig: "",
            useV3EngineHours: false,
            historyRetentionDays: 0,
            harshEventMinSpeed: defaultValue, speedSourcesTrusted: nil
        )

        var accuratePoint: DevicePoint? = nil
        if let status = driveStatus {
            let deviceState = DeviceState(
                driveStatus: status,
                driveStatusId: "",
                driveStatusDuration: defaultUnitValue,
                driveStatusDistance: defaultUnitValue,
                driveStatusLatLngDistance: defaultUnitValue,
                driveStatusBeginTime: now,
                bestDistanceDelta: defaultUnitValue,
                isNewDriveStatus: false,
                adjustedLatLng: LatLng(lat: 0, lng: 0),
                beyondMaxDriftDistance: false,
                prevDriveStatusDuration: defaultUnitValue,
                prevDriveStatusDistance: defaultUnitValue,
                prevDriveStatusLatLngDistance: defaultUnitValue,
                prevDriveStatusBeginTime: nil,
                prevAdjustedLatLng: nil,
                inaccuratePerDeviceSettings: false,
                fuelPercent: nil,
                softwareOdometer: defaultUnitValue,
                lastSoftwareOdometerReadingTime: nil,
                odometer: defaultUnitValue,
                vin: "",
                isVinFromDevicePoint: false,
                counterList: []
            )
            accuratePoint = DevicePoint(
                devicePointId: "",
                dtServer: now,
                dtTracker: now,
                lat: 0,
                lng: 0,
                altitude: nil,
                angle: 0,
                speed: speed,
                params: nil,
                devicePointDetail: nil,
                deviceState: deviceState,
                deviceStateStale: false,
                sequence: ""
            )
        }

        return Device(
            deviceId: "",
            createdAt: now,
            updatedAt: now,
            activatedAt: nil,
            deliveredAt: nil,
            factoryId: "",
            activeState: "",
            displayName: "",
            make: "",
            model: "",
            connData: connData,
            settings: settings,
            userIdList: [],
            online: online,
            latestDevicePoint: accuratePoint,
            latestAccurateDevicePoint: accuratePoint
        )
    }

    func testLatestStatusDuration_NoAccuratePoint_ReturnsDash() {
        let device = makeDevice(online: true, driveStatus: nil, speed: 0)
        XCTAssertEqual(device.latestStatusDuration(), "-", "Should return `-` when no accurate point")
    }

    func testGetCarStatus_Offline_ReturnsOffLine() {
        let device = makeDevice(online: false, driveStatus: nil, speed: 0)
        XCTAssertEqual(device.getCarStatus(), .offLine)
    }

    func testGetCarStatus_DrivingZeroSpeed_ReturnsPaused() {
        let device = makeDevice(online: true, driveStatus: "driving", speed: 0)
        XCTAssertEqual(device.getCarStatus(), .paused)
    }

    func testGetCarStatus_DrivingNonZeroSpeed_ReturnsMoving() {
        let device = makeDevice(online: true, driveStatus: "driving", speed: 10)
        XCTAssertEqual(device.getCarStatus(), .moving)
    }

    func testGetCarStatus_Idle_ReturnsPaused() {
        let device = makeDevice(online: true, driveStatus: "idle", speed: 0)
        XCTAssertEqual(device.getCarStatus(), .paused)
    }

    func testGetCarStatus_UnknownStatus_ReturnsNone() {
        let device = makeDevice(online: true, driveStatus: "foobar", speed: 0)
        XCTAssertEqual(device.getCarStatus(), .none)
    }
}
