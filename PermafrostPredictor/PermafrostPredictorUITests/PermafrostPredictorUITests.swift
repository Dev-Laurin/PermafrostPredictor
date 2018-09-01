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
    
    //entered invalid string into label, submitted, tried again
    func testPopups(){
        
        let app = XCUIApplication()
        let element7 = app.otherElements.containing(.navigationBar, identifier:"Permafrost Predictor").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let element2 = element7.children(matching: .other).element
        let dashedlineImage = element2.children(matching: .image).matching(identifier: "DashedLine").element(boundBy: 0)
        dashedlineImage.swipeUp()
        dashedlineImage.swipeUp()
        dashedlineImage.tap()
        dashedlineImage.tap()
        
        let element = element2.children(matching: .other).element(boundBy: 1)
        element.tap()
        
        let element5 = element7.children(matching: .other).element(boundBy: 2)
        let textField = element5.children(matching: .textField).element(boundBy: 0)
        textField.tap()
        textField.swipeLeft()
        
        let submitButton = app.buttons["Submit"]
        submitButton.tap()
        
        let closeButton = app.alerts["Input Error"].buttons["Close"]
        closeButton.tap()
        element.tap()
        
        let textField2 = element5.children(matching: .textField).element(boundBy: 1)
        textField2.tap()
        submitButton.tap()
        closeButton.tap()
        element.tap()
        textField.tap()
        submitButton.tap()
        textField.tap()
        textField.tap()
        submitButton.tap()
        closeButton.tap()
        element2.children(matching: .image).matching(identifier: "DashedLine").element(boundBy: 1).swipeDown()
        
        let element3 = element2.children(matching: .other).element(boundBy: 2)
        element3.tap()
        textField.tap()
        submitButton.tap()
        closeButton.tap()
        element3.tap()
        textField2.swipeLeft()
        submitButton.tap()
        closeButton.tap()
        element3.tap()
        
        let textField3 = element5.children(matching: .textField).element(boundBy: 2)
        textField3.swipeLeft()
        textField3.tap()
        submitButton.tap()
        closeButton.tap()
        element3.tap()
        
        let textField4 = element5.children(matching: .textField).element(boundBy: 3)
        textField4.tap()
        submitButton.tap()
        closeButton.tap()
        
        let element4 = element2.children(matching: .other).element(boundBy: 3)
        element4.tap()
        textField2.swipeLeft()
        textField2/*@START_MENU_TOKEN@*/.press(forDuration: 0.5);/*[[".tap()",".press(forDuration: 0.5);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        submitButton.tap()
        closeButton.tap()
        element4.tap()
        textField3/*@START_MENU_TOKEN@*/.press(forDuration: 0.6);/*[[".tap()",".press(forDuration: 0.6);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        submitButton.tap()
        closeButton.tap()
        element4.tap()
        textField4.tap()
        element5.tap()
        submitButton.tap()
        closeButton.tap()
        element5.children(matching: .textField).element(boundBy: 4).tap()
        submitButton.tap()
        closeButton.tap()
    }
    
    //test labels changing when dragging 
    func testTempChange(){
        
        let element = XCUIApplication().otherElements.containing(.navigationBar, identifier:"Permafrost Predictor").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0)
        element/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element.swipeDown()
        element.swipeDown()
        element.swipeDown()
        element.swipeDown()
        element.swipeDown()
        element.swipeLeft()
        element.swipeLeft()
        element.swipeLeft()
        element.swipeRight()
        element.swipeRight()
        element.swipeRight()
        element/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
       
    }
    
    //MARK: LocationViewController
    func testLocationViewController(){
        //Give invalid inputs
        
        let app = XCUIApplication()
        let scrollViewsQuery = app.scrollViews
        let element2 = scrollViewsQuery.children(matching: .other).element.children(matching: .other).element
        let element = element2.children(matching: .other).element(boundBy: 1).children(matching: .other).element
        element.swipeUp()
        scrollViewsQuery.otherElements.staticTexts["Snow Layer"].swipeDown()
        
        let element3 = element2.children(matching: .other).element(boundBy: 0).children(matching: .other).element
        let steppersQuery = element3.children(matching: .other).element(boundBy: 0).steppers
        steppersQuery.buttons["Decrement"].tap()
        steppersQuery.buttons["Increment"].tap()
        
        let steppersQuery2 = element3.children(matching: .other).element(boundBy: 1).steppers
        let decrementButton = steppersQuery2.buttons["Decrement"]
        decrementButton.tap()
        steppersQuery2.buttons["Increment"].tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        decrementButton.tap()
        
        let textField = element.children(matching: .textField).element(boundBy: 0)
        textField.tap()
        
        let saveButton = app.navigationBars["Current"].buttons["Save"]
        saveButton.tap()
        app.alerts["Invalid Snow height"].buttons["Click"].tap()
        
        let textField2 = element.children(matching: .textField).element(boundBy: 1)
        textField2.tap()
        saveButton.tap()
        
        let clickButton = app.alerts["Invalid Volumetric Heat Capacity of Snow"].buttons["Click"]
        clickButton.tap()
        textField.tap()
        saveButton.tap()
        clickButton.tap()
        textField2.tap()
        
        let textField3 = element.children(matching: .textField).element(boundBy: 2)
        textField3.tap()
        textField3.tap()
        saveButton.tap()
        app.alerts["Invalid Thermal Conductivity of Snow"].buttons["Click"].tap()
        
        let element4 = element2.children(matching: .other).element(boundBy: 2).children(matching: .other).element
        let textField4 = element4.children(matching: .textField).element
        textField4.tap()
        textField4.tap()
        saveButton.tap()
        app.alerts["Invalid Organic Thickness"].buttons["Click"].tap()
        element2.swipeUp()
        
        let element5 = element4.children(matching: .other).element(boundBy: 1)
        let textField5 = element5.children(matching: .textField).element(boundBy: 0)
        textField5.tap()
        textField5.tap()
        saveButton.tap()
        app.alerts["Invalid Thawed Thermal Conductivity of Organic Layer"].buttons["Click"].tap()
        
        let textField6 = element5.children(matching: .textField).element(boundBy: 1)
        textField6.tap()
        textField6.tap()
        saveButton.tap()
        app.alerts["Invalid Frozen Thermal Conductivity of Organic Layer"].buttons["Click"].tap()
        
        let element6 = element4.children(matching: .other).element(boundBy: 3)
        let textField7 = element6.children(matching: .textField).element(boundBy: 0)
        textField7.tap()
        textField7.tap()
        saveButton.tap()
        app.alerts["Invalid Thawed Volumetric Heat Capacity of Organic Layer"].buttons["Click"].tap()
        
        let textField8 = element6.children(matching: .textField).element(boundBy: 1)
        textField8.tap()
        textField8.tap()
        saveButton.tap()
        app.alerts["Invalid Frozen Volumetric Heat Capacity of Organic Layer"].buttons["Click"].tap()
        element4.children(matching: .other).element(boundBy: 2).swipeUp()
        
        let element7 = element2.children(matching: .other).element(boundBy: 3).children(matching: .other).element
        let textField9 = element7.children(matching: .textField).element
        textField9.tap()
        textField9.tap()
        saveButton.tap()
        app.alerts["Invalid Porosity of Mineral Layer"].buttons["Click"].tap()
        
        let element8 = element7.children(matching: .other).element(boundBy: 1)
        let textField10 = element8.children(matching: .textField).element(boundBy: 0)
        textField10.tap()
        textField10.tap()
        saveButton.tap()
        app.alerts["Invalid Thawed Thermal Conductivity of Mineral Layer"].buttons["Click"].tap()
        
        let textField11 = element8.children(matching: .textField).element(boundBy: 1)
        textField11.tap()
        textField11.tap()
        saveButton.tap()
        app.alerts["Invalid Frozen Thermal Conductivity of Mineral Layer"].buttons["Click"].tap()
    
    }

    func testLocationSaveandLoad(){
        
        let app = XCUIApplication()
        let locationsButton = app.navigationBars["Permafrost Predictor"].buttons["Locations"]
        locationsButton.tap()
        
        let locationsNavigationBar = app.navigationBars["Locations"]
        let addButton = locationsNavigationBar.buttons["Add"]
        addButton.tap()
        
        let currentNavigationBar = app.navigationBars["Current"]
        currentNavigationBar.buttons["Cancel"].tap()
        
        let permafrostPredictorButton = locationsNavigationBar.buttons["Permafrost Predictor"]
        permafrostPredictorButton.tap()
        
        let element4 = app.otherElements.containing(.navigationBar, identifier:"Permafrost Predictor").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let element = element4.children(matching: .other).element
        let image = element.children(matching: .image).element(boundBy: 0)
        image.swipeUp()
        image.swipeUp()
        image.swipeUp()
        locationsButton.tap()
        addButton.tap()
        
        let saveButton = currentNavigationBar.buttons["Save"]
        saveButton.tap()
        permafrostPredictorButton.tap()
        element.children(matching: .image).element(boundBy: 1)/*@START_MENU_TOKEN@*/.press(forDuration: 0.9);/*[[".tap()",".press(forDuration: 0.9);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element.children(matching: .image).element(boundBy: 2).swipeDown()
        locationsButton.tap()
        addButton.tap()
        
        let element2 = app.scrollViews.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1)
        element2.swipeUp()
        saveButton.tap()
        
        let tablesQuery = app.tables
        let loadButton = tablesQuery.children(matching: .cell).element(boundBy: 11).buttons["Load"]
        loadButton.tap()
        locationsButton.tap()
        
        let loadButton2 = tablesQuery.cells.containing(.staticText, identifier:"Fairbanks").buttons["Load"]
        loadButton2.tap()
        locationsButton.tap()
        loadButton.tap()
        
        let element3 = element.children(matching: .other).element(boundBy: 1)
        element3.tap()
        element4.children(matching: .other).element(boundBy: 2).children(matching: .textField).element(boundBy: 0).tap()
        
        let submitButton = app.buttons["Submit"]
        submitButton.tap()
        locationsButton.tap()
        addButton.tap()
        element2.swipeUp()
        saveButton.tap()
        loadButton2.tap()
        locationsButton.tap()
        tablesQuery.children(matching: .cell).element(boundBy: 12).buttons["Load"].tap()
        element3.tap()
        submitButton.tap()
    }
    
    
    
}
