//
//  PermafrostPredictorUITests.swift
//  PermafrostPredictorUITests
//
//  Created by Laurin Fisher on 2/28/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import XCTest
import PermafrostPredictor

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
    
    //entered invalid string into label, submitted, tried again
    func testPopups(){
        
        let app = XCUIApplication()
        let permafrostlineElementsQuery = app.otherElements.containing(.image, identifier:"PermafrostLine")
        let element2 = permafrostlineElementsQuery.children(matching: .other).element
        let element = element2.children(matching: .other).element(boundBy: 1)
        element.tap()
        
        let element3 = permafrostlineElementsQuery.children(matching: .other).element(boundBy: 2)
        let textField = element3.children(matching: .textField).element(boundBy: 0)
        textField.tap()
        
        let submitButton = app.buttons["Submit"]
        submitButton.tap()

        element.tap()
        textField.swipeLeft()
        submitButton.tap()
        submitButton.tap()
        element2.children(matching: .other).element(boundBy: 2).tap()
        
        let textField2 = element3.children(matching: .textField).element(boundBy: 1)
        textField2.tap()
        textField2.tap()
        submitButton.tap()
        
    }
    
    //test labels changing when dragging 
    func testTempChange(){
        
        let element2 = XCUIApplication().otherElements.containing(.image, identifier:"PermafrostLine").children(matching: .other).element
        let element = element2.children(matching: .other).element(boundBy: 0)
        element.swipeLeft()
        element.swipeDown()
        element2.swipeUp()
        element2.swipeUp()
        element2.swipeUp()
        element/*@START_MENU_TOKEN@*/.press(forDuration: 1.2);/*[[".tap()",".press(forDuration: 1.2);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element.swipeUp()
        element2.swipeUp()
        element2.swipeUp()
        element2.swipeUp()
        element.swipeUp()
        element.swipeDown()
        
    }
    
    func testPopupButtonCallback(){
        
    }

    
}
