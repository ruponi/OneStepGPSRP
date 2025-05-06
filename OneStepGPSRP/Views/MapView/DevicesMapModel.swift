//
//  DevicesMapModel.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//
import Foundation
import Combine

@MainActor
final class DeviceMapModel: ObservableObject {
    /// The fetched devices
    @Published var devices: [Device] = []
    /// Any error message from the last fetch
    @Published var errorMessage: String?
    @Published var autoRefresh: Bool = false
    private var timerCancellable: AnyCancellable?
    
    private let service: DeviceServiceProtocol
    private var isLoading = false
    
    /// Initialize with a service (defaults to real network service).
    init(service: DeviceServiceProtocol = DeviceService()) {
        self.service = service
    }
    
    /// Fetches devices, optionally limiting to their latest point.
    ///
    /// - Parameter latestPoint: whether to fetch only the last reported location for each device.
    func loadDevices(latestPoint: Bool = true) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetched = try await service.fetchDevices(latestPoint: latestPoint)
            devices = fetched
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                errorMessage = nil
            }
        }
    }
    
    /// Enable autoload datat every n Secs
    func enableAutoRefresh() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 20, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in Task { await self?.loadDevices() } }
    }
    
    /// Disable autorefresh
    func disableAutoRefresh() {
        timerCancellable?.cancel()
    }
    
}
