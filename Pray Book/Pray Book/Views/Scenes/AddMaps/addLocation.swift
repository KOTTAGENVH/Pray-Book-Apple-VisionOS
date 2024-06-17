//
//  addLocation.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-08.
//

import SwiftUI
import MapKit
import SwiftData

struct addLocation: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContextMap
    @State private var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var searchQuery: String = ""
    @State private var searchQueryHistory: String = ""
    @State private var title: String = ""
    @State private var city: String = ""
    @State private var searchResults: [(String, MKMapItem)] = []
    @State private var selectedLocation: MKMapItem?
    @State private var selectedLocationComplete: Bool = true
    @State private var isSearchLoading: Bool = false
    @State private var isErrorAlertPresented: Bool = false
    @State private var displaySearchBar: Bool = false
    @State private var mapStyle: MapStyle = .standard
    @State private var mapStyleChecker: String = "standard"
    @State private var isAddingPopup: Bool = false
    @State private var isTitleEmpty: Bool = false
    @State private var isCityEmpty: Bool = false
    @State private var isLocationEmpty: Bool = false
    @State private var isLocationAccessdenied: Bool = false
    @State private var buttonLocAccessdenied: Bool = false
    @State private var pinCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @State private var searchPinCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @State private var latitudeDelta: Double = 0.05
    @State private var longitudeDelta: Double = 0.05
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var mapGeometry: CGRect = .zero
    
    
    @StateObject private var networkMonitor = NetworkMonitor() //Check Network
    
    //Start of UI
    var body: some View {
        VStack {
            if displaySearchBar {
                HStack {
                    SearchBar(searchQuery: $searchQuery, onSearch: performSearch)
                    Spacer()
                    
                    if selectedLocationComplete {
                        Button(action: {
                            performSearch(for: searchQuery)
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .cornerRadius(8)
                        }
                    } else {
                        Button(action: {
                            updateListView()
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .cornerRadius(8)
                        }
                    }
                }.padding()
            }
            if !selectedLocationComplete {
                if !searchResults.isEmpty {
                    List(searchResults, id: \.1) { item in
                        Button(action: {
                            selectLocation(item.1)
                        }) {
                            VStack(alignment: .leading) {
                                Text(item.0)
                                    .font(.headline)
                                Text(item.1.name ?? "Unknown")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                        }
                    }
                } else {
                    if !isSearchLoading {
                        Text("No location found!")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }
                }
            }
            MapReader { proxy in
                Map(position: $camera) {//Map
                    Marker(coordinate: searchPinCoordinate) {
                        Label(searchQueryHistory, systemImage: "mappin.and.ellipse")
                    }
                    .tint(.yellow)
                    
                    
                } .mapStyle(mapStyle)
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
                        if let userLocation = CLLocationManager().location?.coordinate {
                            pinCoordinate = userLocation
                            updateCamera(to: userLocation)
                        }
                    }
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            latitude = Double(String(format: "%.6f", coordinate.latitude)) ?? 0.0
                            longitude = Double(String(format: "%.7f", coordinate.longitude)) ?? 0.0
                            print("coordinate: \(coordinate.latitude) coordinate.longitude: \(coordinate.longitude)")
                            searchPinCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            print("searchPinCoordinate: \(searchPinCoordinate) ")
                            print("latitude: \(latitude) latitude \(longitude)")
                        }
                    }
                
            }
        }
        .safeAreaInset(edge: .bottom) { //Content on the bottom beyond safe area
            HStack {
                if mapStyleChecker == "standard" {
                    Button(action: {
                        mapStyle = .standard
                        mapStyleChecker = "hybrid"
                        updateListView()
                    }) {
                        HStack {
                            Image(systemName: "map.circle.fill")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 44))
                        }
                        .padding()
                        .cornerRadius(8)
                    }
                } else if mapStyleChecker == "hybrid" {
                    Button(action: {
                        mapStyle = .hybrid
                        mapStyleChecker = "imagery"
                        updateListView()
                    }) {
                        HStack {
                            Image(systemName: "map.circle.fill")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 44))
                        }
                        .padding()
                        .cornerRadius(8)
                    }
                } else {
                    Button(action: {
                        mapStyle = .imagery
                        mapStyleChecker = "standard"
                        updateListView()
                    }) {
                        HStack {
                            Image(systemName: "map.circle.fill")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 44))
                        }
                        .padding()
                        .cornerRadius(8)
                    }
                }
                if buttonLocAccessdenied {
                    Button(action: {
                        openSettings()
                    }) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 44))
                        }
                        .padding()
                        .cornerRadius(8)
                    }
                }
                Button(action: {
                    self.isAddingPopup = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.system(size: 44))
                    }
                    .padding()
                    .cornerRadius(8)
                }
                .sheet(isPresented: $isAddingPopup) {
                           ZStack {
                               // Background color based on color scheme
                               Color(colorScheme == .dark ? .black : .white)
                                   .opacity(0.8)
                               VStack {  // Start of user inputs for saving
                                   Text("Location:")
                                       .font(.system(size: 24))
                                       .foregroundColor(colorScheme == .dark ? .white : .black)
                                       .padding()

                                   TextField(
                                       "Location Name",
                                       text: $title
                                   )
                                   .onChange(of: title) { newValue in
                                       if newValue.count > 8 {
                                           title = String(newValue.prefix(6))
                                       }
                                   }
                                   .textFieldStyle(RoundedBorderTextFieldStyle())
                                   .foregroundColor(colorScheme == .dark ? .white : .black)
                                   .padding()
                                   .font(.system(size: 24))
                                   if isTitleEmpty {  // Title validation
                                       Text("Title is required")
                                           .foregroundColor(.red)
                                           .padding(.bottom, 8)
                                   }

                                   Text("City:")
                                       .font(.system(size: 24))
                                       .foregroundColor(colorScheme == .dark ? .white : .black)
                                       .padding()
                                   TextField(
                                       "City Name",
                                       text: $city
                                   )
                                   .onChange(of: city) { newValue in
                                       if newValue.count > 8 {
                                           city = String(newValue.prefix(6))
                                       }
                                   }
                                   .textFieldStyle(RoundedBorderTextFieldStyle())
                                   .foregroundColor(colorScheme == .dark ? .white : .black)
                                   .padding()
                                   .font(.system(size: 24))
                                   if isCityEmpty {  // City validation
                                       Text("City is required")
                                           .foregroundColor(.red)
                                           .padding(.bottom, 8)
                                   }

                                   HStack {
                                       Button(action: {
                                           self.isAddingPopup = false
                                       }) {
                                           Text("Close")
                                               .foregroundColor(colorScheme == .dark ? .white : .black)
                                               .padding()
                                               .font(.system(size: 24))
                                               .background(Color.red)
                                               .cornerRadius(8.0)
                                       }
                                       .padding()

                                       Button(action: {
                                           save()
                                       }) {
                                           Text("Save")
                                               .foregroundColor(colorScheme == .dark ? .white : .black)
                                               .padding()
                                               .font(.system(size: 24))
                                               .background(colorScheme == .dark ? Color.buttoncustom1 : Color.indigo)
                                               .cornerRadius(8.0)
                                       }
                                       .padding()
                                   }

                                   if isLocationEmpty {  // Location validation
                                       Text("Please choose a location on the map")
                                           .foregroundColor(.red)
                                           .padding(.bottom, 8)
                                   }
                               }
                           }
                           .frame(width: 400, height: 400)
                       }
                
                if displaySearchBar {
                    Button(action: {
                        closeSearchBar()
                    }) {
                        HStack {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 44))
                        }
                        .padding()
                        .cornerRadius(8)
                    }
                } else {
                    Button(action: {
                        showSearchBar()
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 44))
                        }
                        .padding()
                        .cornerRadius(8)
                    }
                }
            }
        }
        .navigationBarTitle("Spiritual Sites Memorizer", displayMode: .inline)
        .alert(isPresented: $isErrorAlertPresented) { //display error during search
            Alert(title: Text("Error"), message: Text("Sorry! an error occured during search"), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $networkMonitor.isNotConnectedAlertPresented) { //alert for no internet
            Alert(title: Text("Error"), message: Text("You are not connected to the internet."), dismissButton: .default(Text("OK"), action: {
                self.openSettings()
            }))
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $isLocationAccessdenied) {
            Alert(title: Text("Error"), message: Text("Allow access to location"), dismissButton: .default(Text("OK")))
        }
    }
    
    //--------------------------------------------------------------------------
    //**Start of functions**
    
    //Search function
    private func performSearch(for query: String) {
        selectedLocationComplete = false
        isSearchLoading = true
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                // Handle error
                let errorMessage = error?.localizedDescription ?? "An error occurred."
                print("error in performing search \(errorMessage)")
                isErrorAlertPresented = true
                isSearchLoading = false
                return
            }
            
            searchResults = response.mapItems.map { ("\(query) \($0.placemark.locality ?? "") \($0.placemark.country ?? "")", $0) }
            searchQueryHistory = searchQuery
            searchQuery = ""
            isSearchLoading = false
        }
    }
    
    //function for location selection
    private func selectLocation(_ item: MKMapItem) {
        selectedLocation = item
        let coordinate = item.placemark.coordinate
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        pinCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        searchQueryHistory = item.name ?? "Location"
        searchPinCoordinate = coordinate
        print("original cordinate: \(searchPinCoordinate)")
        updateCamera(to: coordinate)
        selectedLocationComplete = true
    }
    
    //Hide List View
    private func updateListView() {
        selectedLocationComplete = true
    }
    
    //Display search bar
    private func showSearchBar() {
        displaySearchBar = true
    }
    
    //Close search bar
    private func closeSearchBar() {
        displaySearchBar = false
        updateListView()
    }
    
    //Update Map Camera
    private func updateCamera(to coordinate: CLLocationCoordinate2D) {
        camera = .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)))
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
    
    //Save Map location
    func save() {
        guard !title.isEmpty else {
            isTitleEmpty = true
            self.isAddingPopup = true
            return
        }
        isTitleEmpty = false
        guard !city.isEmpty else {
            isCityEmpty = true
            self.isAddingPopup = true
            return
        }
        isCityEmpty = false
        // Create CLLocationCoordinate2D instance for location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if location.longitude == 0.0 && location.latitude == 0.0 {
            isLocationEmpty = true
            self.isAddingPopup = true
            return
        } else {
            isLocationEmpty = false
        }
        
        // Create MKCoordinateSpan instance for coordinateSpan
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        // Initialize Maps instance with the correct parameters
        let maps = Maps(title: title, city: city, location: location, coordinateSpan: span)
        
        modelContextMap.insert(maps)
        do {
            try modelContextMap.save()
            self.isAddingPopup = false
        } catch {
            showAlert = true
            alertMessage = "Failed to save prayer"
            print("Failed to save prayer: \(error.localizedDescription)")
            self.isAddingPopup = false
        }
    }
}




#Preview {
    addLocation()
}
