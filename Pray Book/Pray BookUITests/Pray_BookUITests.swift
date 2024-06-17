//  Pray_BookUITests.swift
//  Pray BookUITests
//
//  Created by Nowen on 2024-06-02.
//

import XCTest

class Pray_BookUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    //Navigation to Map
    func testNavigationToMap() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Tap on the map button
        let mapButton = app.navigationBars.buttons["map"]
        XCTAssertTrue(mapButton.exists, "Map button should exist")
        mapButton.tap()
        
        // Verify that the add prayer view is displayed by checking the navigation title
        let mapView = app.navigationBars["Spiritual Site Memorizer"]
        XCTAssertTrue(mapView.exists, "Map view should be displayed after tapping the map button")
    }
    
    //Navigation to Add
    func testNavigationToAddPrayer() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Tap on the add prayer button
        let addButton = app.navigationBars.buttons["plus"]
        XCTAssertTrue(addButton.exists, "Add button should exist")
        addButton.tap()
        
        // Verify that the add prayer view is displayed by checking the navigation title
        let navigationBar = app.navigationBars["Add Prayer"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5), "Add prayer view should be displayed after tapping the add button")
    }
    
    //Test whether the No Content Image is being displayed
    func testNoContentImageDisplayedWhenPrayersEmpty() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Verify that the no content image is displayed
        let noContentImage = app.images["NoContentImage"]
        XCTAssertTrue(noContentImage.exists, "No content image should be displayed")
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
