//
//  DeviceService.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//
import Foundation

/// Asynchronously fetches or creates devices via your GPS API.
protocol DeviceServiceProtocol {
    /// Fetch all devices, optionally only their latest point.
    ///
    /// - Parameter latestPoint: if `true`, the API returns only the most recent location per device.
    /// - Returns: An array of `Device` objects.
    /// - Throws: `NetworkError` on failure.
    func fetchDevices(latestPoint: Bool) async throws -> [Device]
}


// MARK: - Service Implementation

final class DeviceService: DeviceServiceProtocol {
    // MARK: State & Configuration
    private var isRequestInProgress = false
    private var isDebouncing       = false
    
    private let maxRetries   = 3
    private let retryDelay   = 2.0       // base seconds for back-off
    private let debounceDelay = 0.5      // seconds
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        // you could also customize timeout/waitsForConnectivity here
        self.session = session
    }
    
    // MARK: Public Methods
    
    func fetchDevices(latestPoint: Bool) async throws -> [Device] {
        // Throttle / debounce guard
        guard !isRequestInProgress else {
            throw NetworkError.requestThrottled
        }
        guard !isDebouncing else {
            try await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            return try await fetchDevices(latestPoint: latestPoint)
        }
        
        isRequestInProgress = true
        defer { isRequestInProgress = false }
        isDebouncing = true
        defer { isDebouncing = false }
        
        let request = try DeviceEndpoint
            .getDevices(latestPoint: latestPoint)
            .asURLRequest()
        
        // Use the same retry logic
        let data = try await performRequestWithRetry(request: request)
        let decoder = JSONDecoder.iso8601
        let decoded = try decoder.decode(DeviceResponse.self, from: data)
        return decoded.resultList
    }
    
    
    // MARK: Shared Retry Logic
    
    private func performRequestWithRetry(request: URLRequest) async throws -> Data {
        var attempt = 0
        
        while attempt < maxRetries {
            do {
                let (data, resp) = try await session.data(for: request)
                guard let http = resp as? HTTPURLResponse,
                      200..<300 ~= http.statusCode else {
                    throw NetworkError.httpError(statusCode: (resp as? HTTPURLResponse)?.statusCode ?? -1)
                }
                return data
            }
            catch {
                attempt += 1
                if attempt >= maxRetries {
                    throw NetworkError.maxRetryExceeded
                }
                let backoff = retryDelay * pow(2, Double(attempt - 1))
                try await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
            }
        }
        
        throw NetworkError.maxRetryExceeded
    }
}

fileprivate extension JSONDecoder {
    /// A decoder set up for ISO-8601 dates everywhere
    static let iso8601: JSONDecoder = {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            // Try fractional‐seconds first:
            let fractional = ISO8601DateFormatter()
            fractional.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]
            if let date = fractional.date(from: dateStr) {
                return date
            }
            
            // Fallback to plain ISO8601:
            let plain = ISO8601DateFormatter()
            plain.formatOptions = [.withInternetDateTime]
            if let date = plain.date(from: dateStr) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: '\(dateStr)'—expected ISO8601."
            )
        }
        return decoder
    }()
}

