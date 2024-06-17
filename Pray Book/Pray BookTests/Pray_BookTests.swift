import XCTest
import _MapKit_SwiftUI
@testable import Pray_Book
import CoreLocation
import MapKit

final class Pray_BookTests: XCTestCase {
    
    //System Under Test = sut 😅
    var sut: oneMapView!
    var sut2: addPrayer!
    var sut3: PrayerDetailview!
    
    override func setUpWithError() throws {
        let sampleMap = Maps(
            title: "Sample Location",
            city: "Sample City",
            location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            coordinateSpan: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        sut = oneMapView(map: sampleMap)
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    
    //Testing if the setting apps get opened when map permission is denied
    func testOpenSettings() throws {
        // Expectation for settings app to open
        let settingsOpenedExpectation = XCTestExpectation(description: "Settings app opened")
        
        // Open settings
        sut.openSettings()
        
        // Wait for settings app to open
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
                // Settings app is open
                settingsOpenedExpectation.fulfill()
            } else {
                // Settings app is not open
                settingsOpenedExpectation.fulfill()
                XCTFail("Settings app did not open")
            }
        }
        
        // Wait for expectation to be fulfilled
        wait(for: [settingsOpenedExpectation], timeout: 10) // Adjust timeout as necessary
    }
    
    
    //Checking the url generator for sharing locations
    func testGenerateLocationURL() throws {
        //init
        let sampleMap = Maps(
            title: "Sample Location",
            city: "Sample City",
            location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            coordinateSpan: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        let oneMapViewInstance = oneMapView(map: sampleMap)
        
        // checker
        let generatedURL = oneMapViewInstance.generateLocationURL()
        
        // testing
        XCTAssertNotNil(generatedURL)
        XCTAssertEqual(generatedURL?.absoluteString, "https://maps.apple.com/?q=Sample%20Location&ll=37.7749,-122.4194")
    }
    
//    func testCopyPrayerToClipboard() {
//        // Given
//        let description = "Test prayer description"
//        
//        //call func
//        sut3.copyPrayer(description: description)
//        
//        // Delay for a short period 0.5
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            // Test clipboard copy
//            let pasteboard = UIPasteboard.general
//            XCTAssertEqual(pasteboard.string, description)
//        }
//    }
    
}
