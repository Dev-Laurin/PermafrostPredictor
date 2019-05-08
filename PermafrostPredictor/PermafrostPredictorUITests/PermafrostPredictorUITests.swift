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
        tablesQuery.cells.containing(.staticText, identifier:"Fairbanks").buttons["Load"].tap()
        locationsButton.tap()
       
    }
    
    //test that the view detecting the line gesture stays in place
    func testLineGestureRecognizerView(){
        
        //test normal dragging works
        //test snow line
        let app = XCUIApplication()
        let element3 = app.otherElements.containing(.navigationBar, identifier:"Permafrost Predictor").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let element = element3.children(matching: .other).element(boundBy: 2)
        element/*@START_MENU_TOKEN@*/.press(forDuration: 1.9);/*[[".tap()",".press(forDuration: 1.9);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element/*@START_MENU_TOKEN@*/.press(forDuration: 1.1);/*[[".tap()",".press(forDuration: 1.1);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
            //is snow line within this view?
        let snowLine = app.otherElements["snowLine"]
        XCTAssert(element.frame.contains(snowLine.frame));
        //TODO: -------------did the snow line move?
        
        //test organic line works
        let element2 = element3.children(matching: .other).element(boundBy: 3)
        element2.swipeUp()
        element2.swipeDown()
        
        let lineGround = app.otherElements["lineGround"]
            //is the line ground within this view?
        XCTAssert(element2.frame.contains(lineGround.frame))
        //TODO: -------------did the ground line move?
        
        //See if recognizer works after loading new location
        let permafrostPredictorNavigationBar = app.navigationBars["Permafrost Predictor"]
        permafrostPredictorNavigationBar.buttons["Locations"].tap()
        app.tables.cells.containing(.staticText, identifier:"Nome").buttons["Load"].tap()
        element.swipeUp()
        element.swipeDown()
        
        element2.swipeUp()
        element2.swipeDown()
        
        //are the line views still contained under the gesture recognizer?
        XCTAssert(element.frame.contains(snowLine.frame));
        XCTAssert(element2.frame.contains(lineGround.frame))
        
        //TODO -------- did the lines move?
        
        //see if it still works after opening info window
        let itemButton = permafrostPredictorNavigationBar.buttons["Item"]
        itemButton.tap()
        itemButton.tap()
        element3.children(matching: .other).element(boundBy: 1).children(matching: .image).matching(identifier: "DashedLine").element(boundBy: 1).swipeUp()
        element2.swipeUp()
        
        //are the line views still contained under the gesture recognizer?
        XCTAssert(element.frame.contains(snowLine.frame));
        XCTAssert(element2.frame.contains(lineGround.frame))
        
        //TODO -------- did the lines move?
        
    }
    
}
