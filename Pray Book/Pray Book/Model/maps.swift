//
//  maps.swift
//  Pray Book
//
//  Created by Nowen on 2024-06-08.
//

import SwiftData
import MapKit

//Model for Maps
@Model
class Maps {
    var title: String
    var city: String
    var latitude: Double
    var longitude: Double
    var latitudeDelta: Double
    var longitudeDelta: Double
    
    var location: CLLocationCoordinate2D {
        get {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    var coordinateSpan: MKCoordinateSpan {
        get {
            MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        }
        set {
            latitudeDelta = newValue.latitudeDelta
            longitudeDelta = newValue.longitudeDelta
        }
    }
    
    init(
        title: String,
        city: String,
        location: CLLocationCoordinate2D,
        coordinateSpan: MKCoordinateSpan
    ) {
        self.title = title
        self.city = city
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.latitudeDelta = coordinateSpan.latitudeDelta
        self.longitudeDelta = coordinateSpan.longitudeDelta
    }
}
