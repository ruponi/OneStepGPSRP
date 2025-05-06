//
//  Errors.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//

import Foundation

// Represents various networking errors that can occur during API operations.
enum NetworkError: LocalizedError {
    /// Indicates the server response was invalid or in an unexpected format.
      case invalidResponse
      
      /// Represents an HTTP error with a specific status code.
      /// - Parameter statusCode: The HTTP status code received from the server.
      case httpError(statusCode: Int)
      
      /// Indicates a failure to decode the server response into the expected format.
      /// - Parameter Error: The underlying decoding error that occurred.
      case decodingError(Error)
      
      /// Represents a general networking error.
      /// - Parameter Error: The underlying network error that occurred.
      case networkError(Error)
      
      /// Indicates the API request was throttled due to exceeding rate limits.
      case requestThrottled
      
      /// Indicates the maximum number of retry attempts has been exceeded.
      case maxRetryExceeded
      
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .requestThrottled:
            return "Request is throttled. Please try again later."
        case .maxRetryExceeded:
            return "Maximum retry attempts exceeded."
        }
    }
}
