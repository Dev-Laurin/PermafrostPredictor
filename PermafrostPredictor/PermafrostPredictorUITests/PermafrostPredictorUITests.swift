//
//  PermafrostPredictorUITests.swift
//  PermafrostPredictorUITests
//
//  Created by Laurin Fisher on 2/28/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import XCTest

class PermafrostPredictorUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //used to test if anything crashes
    func testOrganicLayerMovement(){
        let dashedlineImage = XCUIApplication().otherElements.containing(.image, identifier:"PermafrostLine").children(matching: .other).element.children(matching: .image).matching(identifier: "DashedLine").element(boundBy: 1)
        dashedlineImage.swipeDown()
        dashedlineImage.swipeUp()
        dashedlineImage.swipeDown()
        
    }
    
    func testSnowMovement(){
        let dashedlineImage = XCUIApplication().otherElements.containing(.image, identifier:"PermafrostLine").children(matching: .other).element.children(matching: .image).matching(identifier: "DashedLine").element(boundBy: 0)
        dashedlineImage.swipeUp()
        dashedlineImage.tap()
        dashedlineImage/*@START_MENU_TOKEN@*/.press(forDuration: 0.5);/*[[".tap()",".press(forDuration: 0.5);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        dashedlineImage.swipeDown()
        
    }
    
    //MARK: LocationViewController
    func testLocationViewController(){
        
        let app = XCUIApplication()
        app.navigationBars["Permafrost Predictor"].buttons["Locations"].tap()
        app.navigationBars["Locations"].buttons["Add"].tap()
        
        let element6 = app.scrollViews.children(matching: .other).element.children(matching: .other).element
        let element = element6.children(matching: .other).element(boundBy: 0).children(matching: .other).element

        let element2 = element6.children(matching: .other).element(boundBy: 1)
        element2.swipeUp()
        
        let element3 = element6.children(matching: .other).element(boundBy: 3)
        element3.swipeUp()
        
        let element7 = element6.children(matching: .other).element(boundBy: 2).children(matching: .other).element
        let element4 = element7.children(matching: .other).element(boundBy: 1)
        element4.children(matching: .textField).element(boundBy: 0).tap()
        
        let textField = element7.children(matching: .textField).element
        textField.tap()
        textField.tap()
        
        let textField2 = element4.children(matching: .textField).element(boundBy: 1)
        textField2.tap()
        textField2.tap()
        
        let element8 = element7.children(matching: .other).element(boundBy: 3)
        let textField3 = element8.children(matching: .textField).element(boundBy: 1)
        textField3.tap()
        textField3.tap()
        
        let textField4 = element8.children(matching: .textField).element(boundBy: 0)
        textField4.tap()
        textField4.tap()
        
        let element9 = element3.children(matching: .other).element
        let textField5 = element9.children(matching: .textField).element
        textField5.tap()
        textField5.tap()
        
        let element10 = element9.children(matching: .other).element(boundBy: 1)
        let textField6 = element10.children(matching: .textField).element(boundBy: 0)
        textField6.tap()
        textField6.tap()
        
        let textField7 = element10.children(matching: .textField).element(boundBy: 1)
        textField7.tap()
        textField7.tap()
        
        let element11 = element9.children(matching: .other).element(boundBy: 3)
        let textField8 = element11.children(matching: .textField).element(boundBy: 1)
        textField8.tap()
        textField8.tap()
        
        let textField9 = element11.children(matching: .textField).element(boundBy: 0)
        textField9.tap()
        textField9.tap()
        element10.swipeDown()
        
        let element5 = element2.children(matching: .other).element
        element5.tap()
        
        let textField10 = element5.children(matching: .textField).element(boundBy: 0)
        textField10.tap()
        textField10.tap()
        
        let textField11 = element5.children(matching: .textField).element(boundBy: 1)
        textField11.tap()
        textField11.tap()
        
        let textField12 = element5.children(matching: .textField).element(boundBy: 2)
        textField12.tap()
        textField12.tap()
        element2.swipeDown()
        
        let textField13 = element6.children(matching: .textField).element
        textField13.tap()
        textField13.tap()
        app.navigationBars["Current"].buttons["Save"].tap()
       
    }

    func testLocationSaveandLoad(){
        
        let app = XCUIApplication()
        let locationsButton = app.navigationBars["Permafrost Predictor"].buttons["Locations"]
        locationsButton.tap()
        app.navigationBars["Locations"].buttons["Add"].tap()
        
        let element3 = app.scrollViews.children(matching: .other).element.children(matching: .other).element
        let element = element3.children(matching: .other).element(boundBy: 1)
        element.swipeUp()
        element3.children(matching: .other).element(boundBy: 2)/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeDown()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
        let element2 = element.children(matching: .other).element
        element2.children(matching: .textField).element(boundBy: 0).tap()
        app.navigationBars["Current"].buttons["Save"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier:"Fairbanks").buttons["Load"].tap()
        locationsButton.tap()
        tablesQuery.cells.containing(.staticText, identifier:"Default").buttons["Load"].tap()
        locationsButton.tap()
        tablesQuery.children(matching: .cell).element(boundBy: 7).buttons["Load"].tap()
        
       
    }
    
    
    
}
