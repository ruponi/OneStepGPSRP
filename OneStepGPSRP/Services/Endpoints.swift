//
//  Endpoints.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//

import Foundation
//Generally we can setup different baseURLs for different application Schemes: Dev, stage, product ets.

/// Protocol: anything that can produce a URLRequest
protocol RequestConvertible {
  func asURLRequest() throws -> URLRequest
}

enum HTTPMethod: String {
  case get     = "GET"
  case post    = "POST"
  case put     = "PUT"
  case delete  = "DELETE"
}

/// All the public endpoints your app calls
enum DeviceEndpoint {
    /// GET  all devices
    case getDevices(latestPoint: Bool)
    
    private var path: String {
        switch self {
        case .getDevices:
            return "/device"
        }
    }
    
    private var method: HTTPMethod {
        switch self {
        case .getDevices:     return .get
            // Some additinal methods
        }
    }
    
    /// Common query items applied to every request
    private var commonQueryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "api-key", value: APIConfig.apiKey)
        ]
    }
    
    /// Endpoint-specific query items
    private var extraQueryItems: [URLQueryItem] {
        switch self {
        case .getDevices(let latest):
            return [
                URLQueryItem(name: "latest_point", value: latest ? "true" : "false")
            ]
        }
    }
    
    /// Full URL for this endpoint, including queries
    func url() -> URL {
        var comps = URLComponents(url: APIConfig.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        comps.queryItems = commonQueryItems + extraQueryItems
        return comps.url!
    }
    
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: url())
        request.httpMethod = method.rawValue
        return request
    }
}
