//
//  ContentView.swift
//  OneStepGPSRP
//
//  Created by Ruslan Ponomarenko on 4/30/25.
//

import SwiftUI
import SwiftData
import UIKit
import MapKit
import CoreLocation

// MARK: - Device Identifiable conformance
extension Device: Identifiable {
    var id: String { deviceId }
}

/// A SwiftUI wrapper for a UIKit MKMapView showing clustered device annotations.
struct DeviceMapView: View {
    @StateObject private var viewModel = DeviceMapModel()
    @State private var mapView: MKMapView? = nil
    
    @State private var zoomAll: Bool = true
    @State private var autoRefresh = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                // Map view with zoomAll control
                DeviceMapUIKitView(devices: viewModel.devices,
                                   zoomAll: $zoomAll,
                                   mapView: $mapView)
                .ignoresSafeArea()
                .onAppear {
                    Task { await viewModel.loadDevices(latestPoint: true) }
                }
                .onReceive(viewModel.$autoRefresh) { enabled in
                    enabled ? viewModel.enableAutoRefresh() : viewModel.disableAutoRefresh()
                } .overlay(
                    // Error banner
                    Group {
                        if let message = viewModel.errorMessage {
                            Text(message)
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(8)
                                .padding(.top, 50)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeInOut, value: viewModel.errorMessage)
                        }
                    }, alignment: .top
                )
                
                // Control buttons
                VStack(spacing: 12) {
                    // 1. Show all pins
                    Button(action: { zoomAll.toggle() }) {
                        Image(systemName: "square.arrowtriangle.4.outward")
                            .font(.title2)
                            .padding()
                            .background(Color.mainButton)
                            .clipShape(Circle())
                    }
                    
                    //Navigate to list view
                    NavigationLink(destination: DeviceListView(devices: viewModel.devices) { device in
                        // onSelect: center map on tapped device
                        if let map = mapView {
                            let coord = CLLocationCoordinate2D(latitude: device.latestAccurateDevicePoint?.lat ?? 0,
                                                               longitude: device.latestAccurateDevicePoint?.lng ?? 0)
                            map.setCenter(coord, animated: true)
                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            map.setRegion(MKCoordinateRegion(center: coord, span: span), animated: true)
                            zoomAll = false
                        }
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.title2)
                            .padding(15)
                            .background(Color.mainButton)
                            .clipShape(Circle())
                    }
                    // Refresh toggle button
                    Button(action: { viewModel.autoRefresh.toggle() }) {
                        Image(systemName: viewModel.autoRefresh ? "arrow.clockwise.circle.fill" : "arrow.clockwise.circle")
                            .font(.title2)
                            .padding(13)
                            .background(Color.mainButton)
                            .clipShape(Circle())
                    }.padding(.top, 20)
                }
                .padding(.top,50)
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

    /// Annotation subclass for Device
final class DeviceAnnotation: NSObject, MKAnnotation {
    let device: Device
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(device: Device) {
        self.device = device
        self.coordinate = .init(latitude: 0, longitude: 0)
    }
}
 
// MARK: - Preview
struct DeviceMapView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceMapView()
    }
}
