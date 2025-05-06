//
//  SequenceExtensions.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 5/4/25.
//

import CoreLocation
import MapKit
import Foundation

// MARK: - Bounding region extension
extension Sequence where Element: MKAnnotation {
    /// Computes a map region that encloses all annotations, with padding.
    func boundingRegion(paddingFactor: Double = 1.2) -> MKCoordinateRegion? {
        let coords = compactMap { $0.coordinate }
        guard !coords.isEmpty else { return nil }
        let lats = coords.map { $0.latitude }
        let lons = coords.map { $0.longitude }
        guard let minLat = lats.min(), let maxLat = lats.max(),
              let minLon = lons.min(), let maxLon = lons.max() else {
            return nil
        }
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * paddingFactor,
            longitudeDelta: (maxLon - minLon) * paddingFactor
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}
