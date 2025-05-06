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
            // Cluster view
            self.mapView = mapView
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                    for: cluster
                ) as! MKMarkerAnnotationView
                view.markerTintColor = .systemBlue
                view.glyphText = "\(cluster.memberAnnotations.count)"
                view.canShowCallout = false
                return view
            }
            
            // Device annotation view
            guard let deviceAnn = annotation as? DeviceAnnotation else { return nil }
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
                for: deviceAnn
            ) as! MKMarkerAnnotationView
            
            // Marker appearance by status
            let carStatus = deviceAnn.device.getCarStatus()
            let iconImage: UIImage? = carStatus.uiImage
            let iconColor: UIColor = carStatus.statusColor
            
            if carStatus == .moving, let iconImage = iconImage  {
                let rotated: UIImage = {
                    let angle = deviceAnn.device.latestAccurateDevicePoint?.angle ?? 0
                    let radians = CGFloat(angle+90) * .pi / 180
                    let renderer = UIGraphicsImageRenderer(size: iconImage.size)
                    return renderer.image { ctx in
                        let mid = CGPoint(x: iconImage.size.width/2, y: iconImage.size.height/2)
                        ctx.cgContext.translateBy(x: mid.x, y: mid.y)
                        ctx.cgContext.rotate(by: radians)
                        ctx.cgContext.translateBy(x: -mid.x, y: -mid.y)
                        iconImage.draw(at: .zero)
                    }
                }()
                view.glyphImage = rotated
                
            } else {
                view.glyphImage = iconImage
            }
            
            view.markerTintColor = iconColor
            view.titleVisibility    = .hidden
            view.subtitleVisibility = .hidden
            deviceAnn.title = nil
            view.clusteringIdentifier = "device"
            view.canShowCallout = true
            
            // add (or update) your own Marker Label for on-map title
            let tag = 999
            // Custom label under pin
            if let labelView = view.viewWithTag(tag) as? PinLabelView {
                labelView.setText(deviceAnn.device.displayName)
            } else {
                let labelView = PinLabelView(text: deviceAnn.device.displayName)
                labelView.tag = tag
                labelView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(labelView)
                labelView.center = CGPoint(x: view.bounds.midX, y: labelView.bounds.height+20)
                NSLayoutConstraint.activate([
                    labelView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 5),
                    labelView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
            }
            
            // Custom callout content
            let calloutView = DeviceCalloutView(device: deviceAnn.device)
            let host = UIHostingController(rootView: calloutView)
            host.view.translatesAutoresizingMaskIntoConstraints = false
            host.view.backgroundColor = .clear
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(host.view)
            NSLayoutConstraint.activate([
                host.view.topAnchor.constraint(equalTo: container.topAnchor),
                host.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                host.view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
            
            // 3. The “Zoom” button
            let zoomButton = ZoomButton(type: .system)
            zoomButton.setTitle("Zoom", for: .normal)
            zoomButton.coordinate = deviceAnn.coordinate
            zoomButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            zoomButton.setTitleColor(.black, for: .normal)
            zoomButton.layer.borderColor = UIColor.black.cgColor
            zoomButton.layer.borderWidth = 1
            zoomButton.layer.cornerRadius = 4
            zoomButton.translatesAutoresizingMaskIntoConstraints = false
            zoomButton.addTarget(self, action: #selector(zoomButtonTapped(_:)), for: .touchUpInside)
            
            container.addSubview(zoomButton)
            NSLayoutConstraint.activate([
                zoomButton.topAnchor.constraint(equalTo: host.view.bottomAnchor, constant: 8),
                zoomButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                zoomButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                zoomButton.widthAnchor.constraint(equalToConstant: 50),
                zoomButton.heightAnchor.constraint(equalToConstant: 25)
            ])
            
            view.detailCalloutAccessoryView = container
            
            
            return view
        }
        
        @objc private func zoomButtonTapped(_ sender: ZoomButton) {
            guard let map = mapView, let coord = sender.coordinate else { return }
            
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            let region = MKCoordinateRegion(center: coord, span: span)
            map.setRegion(region, animated: true)
            parent.zoomAll = false
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

