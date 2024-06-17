//
//  oneMapView.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-10.
//

import SwiftUI
import MapKit
import CoreLocation

struct oneMapView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var camera: MapCameraPosition  = .userLocation(fallback: .automatic)
    @State private var selectedLocation: MKMapItem?
    @State private var pinCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @State private var latitudeDelta: Double = 0.05
    @State private var longitudeDelta: Double = 0.05
    @State private var mapStyle: MapStyle = .standard
    @State private var mapStyleChecker: String = "standard"
    @State private var noOfKm: String = ""
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var route: MKRoute?
    @State private var showingShareSheet = false
    @State private var showdirectionAlert = false
    @State private var isLocationAccessdenied: Bool = false
    @State private var buttonLocAccessdenied: Bool = false
    @State private var transportType = MKDirectionsTransportType.automobile
    
    let map: Maps
    
    var body: some View {
        ZStack {
            Map(position: $camera){ // Map
                Marker(map.title, systemImage: "mappin", coordinate: map.location)
                    .tint(.yellow)
                if let route = route {
                    MapPolyline(route.polyline)
                        .stroke(Color.blue, lineWidth: 6)
                }
            }
            .mapStyle(mapStyle)
            .mapControls {
                MapScaleView()
                MapUserLocationButton()
                MapPitchToggle()
                MapCompass()
                    .mapControlVisibility(.visible)
            }
            .controlSize(.large)
            .onAppear {
                
                checkLocationAuthorization()
                if let currentLocation = CLLocationManager().location?.coordinate {
                    userLocation = currentLocation
                    pinCoordinate = currentLocation
                    updateCamera(to: currentLocation)
                    updateDistance(to: map.location)
                    Task {
                        await fetchRoute(to: map.location)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) { // Content on the bottom beyond safe area
            HStack {
                Button(action: {
                    cycleMapStyle()
                }) {
                    HStack {
                        Image(systemName: "map.circle.fill")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.system(size: 34))
                    }
                    .padding()
                    .cornerRadius(8)
                }
                Button(action: {
                    if map.location.latitude != 0.0 && map.location.longitude != 0.0 {
                        // Initially focus on map.location if it's not empty
                        updateCamera(to: map.location)
                    } else {
                        updateCamera(to: userLocation ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
                    }
                }) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.system(size: 34))
                    }
                    .padding()
                    .cornerRadius(8)
                }
                Text("\(noOfKm) km") //no Of km
                    .padding()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.system(size: 24))
                if buttonLocAccessdenied {
                    Button(action: {
                        openSettings()
                    }) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 34))
                        }
                        .padding()
                        .cornerRadius(8)
                    }
                } else{
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.circle.fill")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 34))
                        }
                        .padding()
                        .cornerRadius(8)
                    }
                }
            }
            .navigationTitle(map.title)
            .font(.title3)
        }
        .alert(isPresented: $showdirectionAlert) {
            Alert(title: Text("Error"), message: Text("Sorry! Direction not available for this location"), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $isLocationAccessdenied) {
            Alert(title: Text("Error"), message: Text("Allow access to location"), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showingShareSheet, onDismiss: {
            showingShareSheet = false
        }) {
            if let url = generateLocationURL() {
                ShareSheet(activityItems: [url])
                    .presentationDetents([.medium,.large])
                    .presentationContentInteraction(.resizes)
            }
        }
    }
    
    // Update Map Camera
    func updateCamera(to coordinate: CLLocationCoordinate2D) {
        camera = .region(MKCoordinateRegion(center: coordinate, span: map.coordinateSpan))
    }
    
    // Cycle through map styles
    func cycleMapStyle() {
        if mapStyleChecker == "standard" {
            mapStyle = .hybrid
            mapStyleChecker = "imagery"
        } else if mapStyleChecker == "hybrid" {
            mapStyle = .imagery
            mapStyleChecker = "standard"
        } else {
            mapStyle = .standard
            mapStyleChecker = "hybrid"
        }
    }
    
    // Update distance in km from user location to map location
    func updateDistance(to location: CLLocationCoordinate2D) {
        print("location extract: \(location)")
        guard let userLocation = userLocation else { return }
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let mapLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let distance = userLoc.distance(from: mapLoc) / 1000.0 // distance in kilometers
        print("distance extract: \(distance)")
        print("mapLoc extract: \(mapLoc)")
        if(distance == 8907.094247343917){
            noOfKm = String("0")
        }else{
            noOfKm = String(format: "%.2f", distance)
        }
    }
    
    // Generate URL for the location
    func generateLocationURL() -> URL? {
        let latitude = map.location.latitude
        let longitude = map.location.longitude
        let urlString = "https://maps.apple.com/?q=\(map.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&ll=\(latitude),\(longitude)"
        return URL(string: urlString)
    }
    
    // Fetch route
    func fetchRoute(to location: CLLocationCoordinate2D) async {
        guard let userLocation = userLocation else { return }
        
        let request = MKDirections.Request()
        
        let sourcePlacemark = MKPlacemark(coordinate: userLocation)
        let routeSource = MKMapItem(placemark: sourcePlacemark)
        
        let destinationPlacemark = MKPlacemark(coordinate: location)
        let routeDestination = MKMapItem(placemark: destinationPlacemark)
        
        request.source = routeSource
        request.destination = routeDestination
        request.transportType = transportType
        
        let directions = MKDirections(request: request)
        
        do {
            let result = try await directions.calculate()
            route = result.routes.first
        } catch {
            showdirectionAlert = true
            print("Error calculating directions: \(error)")
        }
    }
    
    //Check location authorization
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            isLocationAccessdenied = false
            buttonLocAccessdenied = false
            break
        case .denied:
            isLocationAccessdenied = true
            buttonLocAccessdenied = true
            break
        case .notDetermined:
            CLLocationManager().requestWhenInUseAuthorization()
        case .restricted:
            isLocationAccessdenied = true
            buttonLocAccessdenied = true
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    //Open settings to allow location
    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
    
}

struct MapDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMap = Maps(
            title: "Sample Location",
            city: "Sample City",
            location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            coordinateSpan: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        return oneMapView(map: sampleMap)
    }
}
