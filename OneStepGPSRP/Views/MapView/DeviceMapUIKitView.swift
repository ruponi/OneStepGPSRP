//
//  DeviceMapUIKitView.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 5/4/25.
//
import UIKit
import Foundation
import MapKit
import SwiftUI

// MARK: - Storage Keys
struct StorageKeys {
    static let sortOption = "DeviceListView.sortOption"
    static let hiddenIDs = "DeviceListView.hiddenDeviceIDs"
}

// UIViewRepresentable wrapping MKMapView with clustering support.
struct DeviceMapUIKitView: UIViewRepresentable {
    let devices: [Device]
    @Binding var zoomAll: Bool
    @Binding var mapView: MKMapView?
    @AppStorage(StorageKeys.hiddenIDs) private var hiddenIDsData: Data = Data()
    
    /// Computes visible devices by filtering out hidden IDs
    private var visibleDevices: [Device] {
        let ids = (try? JSONDecoder().decode([String].self, from: hiddenIDsData)).map(Set.init) ?? []
        return devices.filter { !ids.contains($0.deviceId) }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        // Register default and cluster annotation views
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )
        DispatchQueue.main.async { self.mapView = mapView }
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Remove old annotations
        let old = uiView.annotations.filter { $0 is DeviceAnnotation || $0 is MKClusterAnnotation }
        uiView.removeAnnotations(old)
        
        // Create new annotations
        let annotations = visibleDevices.compactMap { device -> DeviceAnnotation? in
            guard let pt = device.latestAccurateDevicePoint else { return nil }
            let ann = DeviceAnnotation(device: device)
            ann.coordinate = CLLocationCoordinate2D(latitude: pt.lat ?? 0, longitude: pt.lng ?? 0)
            ann.title = device.displayName
            // ann.title = nil
            return ann
        }
        uiView.addAnnotations(annotations)
        
        // If zoomAll is triggered, fit region
        if zoomAll, let region = (annotations as [MKAnnotation]).boundingRegion() {
            uiView.setRegion(region, animated: true)
            DispatchQueue.main.async { zoomAll = false }
        }
    }
    
    
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: DeviceMapUIKitView
        weak var mapView: MKMapView?
        // Button subclass carrying coordinate
        class ZoomButton: UIButton {
            var coordinate: CLLocationCoordinate2D?
        }
        init(_ parent: DeviceMapUIKitView) { self.parent = parent }
        
     
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
             self.mapView = mapView

             if let cluster = annotation as? MKClusterAnnotation {
                 return makeClusterView(for: cluster, on: mapView)
             }
             guard let deviceAnn = annotation as? DeviceAnnotation else { return nil }
             return makeDeviceView(for: deviceAnn, on: mapView)
         }
        
        // MARK: - Hide pin label when callout is open
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let ann = view.annotation as? DeviceAnnotation else { return }
            // Refresh callout display
            mapView.selectAnnotation(ann, animated: false)
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        }
        
        func mapView(_ mapView: MKMapView,
                     annotationView view: MKAnnotationView,
                     calloutAccessoryControlTapped control: UIControl) {
            if let ann = view.annotation as? DeviceAnnotation {
                // Handle tapping detail button
                print("Tapped callout for device: \(ann.device.deviceId)")
            }
        }
    }
    
    
    
}

//MARK: - Implement Coordinator Functionality
extension DeviceMapUIKitView.Coordinator {
    // MARK: - Cluster View
    private func makeClusterView(for cluster: MKClusterAnnotation,
                                 on mapView: MKMapView) -> MKMarkerAnnotationView {
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
            for: cluster
        ) as! MKMarkerAnnotationView
        view.markerTintColor = .systemBlue
        view.glyphText = "\(cluster.memberAnnotations.count)"
        view.canShowCallout = false
        return view
    }

    // MARK: - Device Annotation View
    private func makeDeviceView(for annotation: DeviceAnnotation,
                                on mapView: MKMapView) -> MKMarkerAnnotationView {
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
            for: annotation
        ) as! MKMarkerAnnotationView

        // Appearance
        let status = annotation.device.getCarStatus()
        view.markerTintColor = status.statusColor
        view.glyphImage = rotatedIcon(for: status, angle: annotation.device.latestAccurateDevicePoint?.angle)
        view.titleVisibility    = .hidden
        view.subtitleVisibility = .hidden
        view.clusteringIdentifier = "device"
        view.canShowCallout = true
        view.titleVisibility    = .hidden
        view.subtitleVisibility = .hidden
        annotation.title = nil

        // Label under pin
        addLabel(to: view, text: annotation.device.displayName)

        // Callout and Zoom button
        view.detailCalloutAccessoryView = makeCalloutContainer(for: annotation)

        return view
    }

    // MARK: - Icon Rotation
    private func rotatedIcon(for status: CarStatus, angle: Int?) -> UIImage? {
        guard status == .moving,
              let base = status.uiImage,
              let deg = angle
        else { return status.uiImage }

        let radians = CGFloat(deg + 90) * .pi/180
        return UIGraphicsImageRenderer(size: base.size)
            .image { ctx in
                let mid = CGPoint(x: base.size.width/2, y: base.size.height/2)
                ctx.cgContext.translateBy(x: mid.x, y: mid.y)
                ctx.cgContext.rotate(by: radians)
                ctx.cgContext.translateBy(x: -mid.x, y: -mid.y)
                base.draw(at: .zero)
            }
    }

    // MARK: - Pin Label
    private func addLabel(to view: MKAnnotationView, text: String) {
        let tag = 999
        if let existing = view.viewWithTag(tag) as? PinLabelView {
            existing.setText(text)
        } else {
            let label = PinLabelView(text: text)
            label.tag = tag
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 5),
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }
    }

    // MARK: - Callout Container
    private func makeCalloutContainer(for ann: DeviceAnnotation) -> UIView {
        let host = UIHostingController(rootView: DeviceCalloutView(device: ann.device))
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: container.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        let zoomBtn = ZoomButton(type: .system)
        zoomBtn.coordinate = ann.coordinate
        zoomBtn.setTitle("Zoom", for: .normal)
        zoomBtn.titleLabel?.font = .systemFont(ofSize: 12)
        zoomBtn.setTitleColor(.black, for: .normal)
        zoomBtn.layer.borderColor = UIColor.black.cgColor
        zoomBtn.layer.borderWidth = 1
        zoomBtn.layer.cornerRadius = 4
        zoomBtn.translatesAutoresizingMaskIntoConstraints = false
        zoomBtn.addTarget(self, action: #selector(zoomButtonTapped(_:)), for: .touchUpInside)

        container.addSubview(zoomBtn)
        NSLayoutConstraint.activate([
            zoomBtn.topAnchor.constraint(equalTo: host.view.bottomAnchor, constant: 8),
            zoomBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            zoomBtn.widthAnchor.constraint(equalToConstant: 50),
            zoomBtn.heightAnchor.constraint(equalToConstant: 25),
            zoomBtn.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }
    
    @objc private func zoomButtonTapped(_ sender: ZoomButton) {
        guard let map = mapView, let coord = sender.coordinate else { return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: coord, span: span)
        map.setRegion(region, animated: true)
        parent.zoomAll = false
    }
}
