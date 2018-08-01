//
//  PermafrostPredictorTests.swift
//  PermafrostPredictorTests
//
//  Created by Laurin Fisher on 2/28/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import XCTest
@testable import PermafrostPredictor

class PermafrostPredictorTests: XCTestCase {
   // var vc : ViewController!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
   //     let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
  //      vc = storyboard.instantiateInitialViewController() as! ViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
  //      vc = nil
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //test the crop image helper function
    func testcropImage(){
        //Test If the image is sized correctly
        let newImageSize : CGFloat = 50
        let image = UIImage(named: "Sun")
        var imageView = UIImageView(image: image)
        let newImage = cropImage(image: imageView.image!, newWidth: imageView.frame.width, newHeight: newImageSize)

        //Assert
        XCTAssert(newImage.size.height == newImageSize)
        
        
        //Test if imageview sized, then image cropped, then imageView sized again works?
        imageView.frame = CGRect(origin: CGPoint(x: imageView.frame.minX, y: imageView.frame.minY), size: CGSize(width: imageView.frame.width, height: newImageSize))
        imageView.image = newImage
        imageView.frame = CGRect(origin: CGPoint(x: imageView.frame.minX, y: imageView.frame.minY), size: CGSize(width: imageView.frame.width, height: newImageSize))
        //Assert
        XCTAssert(newImage.size.height == newImageSize)
        XCTAssert(imageView.image?.size.height == newImageSize)
        
        
        
        //Test uploading the image again, cropping, and changing imageView bounds
        let img = UIImage(named: "Sun")
        imageView = UIImageView(image: img)
        imageView.image = cropImage(image: imageView.image!, newWidth: imageView.frame.width, newHeight: 20)
        imageView.frame = CGRect(origin: CGPoint(x: imageView.frame.minX, y: imageView.frame.minY), size: CGSize(width: (imageView.frame.width),height: 20))
        
        XCTAssert(imageView.image?.size.height == 20)
    }
    
    func testMovementIntoUnits(){
       //Units should be both negative and positive numbers
        XCTAssert(turnMovementIntoUnits(movement: 35) == 7)
        XCTAssert(turnMovementIntoUnits(movement: 0) == 0)
        XCTAssert(turnMovementIntoUnits(movement: 5) == 1)
        XCTAssert(turnMovementIntoUnits(movement: -5) == -1)
        XCTAssert(turnMovementIntoUnits(movement: -30) == -6)
    }
    
    func testTurnTranslationIntoTemp(){
        XCTAssert(turnTranslationIntoTemp(translation: CGPoint(x: 3, y: 4)) == 1)
        XCTAssert(turnTranslationIntoTemp(translation: CGPoint(x: -3, y: -4)) == 1)
        XCTAssert(turnTranslationIntoTemp(translation: CGPoint(x: 0, y:0)) == 0)
    }
    
    func testRoundToHundredths(){
        XCTAssert(roundToHundredths(num: 1.55555) == 1.56)
        XCTAssert(roundToHundredths(num: 0.05) == 0.05)
        XCTAssert(roundToHundredths(num: -3.356) == -3.36)
        XCTAssert(roundToHundredths(num: 1.22222) == 1.22)
    }
    
    func testRoundToThousandths(){
        XCTAssert(roundToThousandths(num: 1.7772) == 1.777)
        XCTAssert(roundToThousandths(num: 0.05) == 0.05)
        XCTAssert(roundToThousandths(num: -4.2323) == -4.232)
        XCTAssert(roundToThousandths(num: 3.2347) == 3.235)
    }
    
    func testChangeViewsYValue(){
        //changes the frame values
        var tempView = UIView()
        tempView = changeViewsYValue(view: tempView, newX: 50, newY: 50)
        XCTAssert(tempView.frame.minX == 50)
        XCTAssert(tempView.frame.minY == 50)
        
        tempView = changeViewsYValue(view: tempView, newX: -50, newY: 0)
        XCTAssert(tempView.frame.minX == -50)
        XCTAssert(tempView.frame.minY == 0)
        
    }

    //test the permafrost calculating functions
    func testMatlabConvertedFunctions(){
        //test given by stakeholder - May 22, 2018
        var temp: Double = 0
        XCTAssert(roundToThousandths(num: CGFloat(computePermafrost(Kvf: 0.25, Kvt: 0.1, Kmf: 1.8, Kmt: 1.0, Cmf: 2000000, Cmt: 3000000, Cvf: 1000000, Cvt: 2000000, Hs: 0.3, Hv: 0.25, Cs: 500000, Tgs: &temp, tTemp: -2, aTemp: 17, eta: 0.45, Ks: 0.15))) == 0.86)
    }
    
    //testing the popup class
    func testPopupView(){
        //test the default size
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        //popup should initially be 75% of the screen - until resizing
        let height = screenHeight * 0.75
        let width = screenWidth * 0.75
        let popup = PopUpView()
        XCTAssert(popup.frame.width == width)
        XCTAssert(popup.frame.height == height)
        
        //resize an empty popup
        popup.resizeView()
        XCTAssert(popup.frame.width == width)
        XCTAssert(popup.frame.height == height)
        
        //call the non-existant callback? - inaccessable - pass
        //popup.submitButtoncallback([1: "test"])
        
        //resize a popup with a title
        popup.addTitle(title: "test")
        popup.resizeView()
        
        //add a button - test callback
        popup.addButton(buttonText: "submit", callback: buttonPressed)
        
        //calling button pressed functions early - unaccessable -pass
        //popup.submitButtonPressed()
        
        popup.exit()
    }
    
    //for the popup class test - the button callback
    func buttonPressed(dict: [Int: String]){
        //nothing - doesn't get called due to lack of UI
    }

    //test the getmovement helper function -- no longer requires UIViews, so we can
    //  test with normal numbers
    func testGetMovementValid(){
    
       //Test 1 - shrinking previous view too much with new height
       
       //given
       //Where the previous view is on the screen
        var previousMinY: CGFloat = 0.0
        var previousHeight: CGFloat = 40.0 //previous view has a height of 40
        var previousHeightBound: CGFloat = 20.0 //can't have height lower than 20
        
        //view below
        var heightBound: CGFloat = 10
        var newYValue: CGFloat = 19 //just below the previous height bound
        
        var lineHeight: CGFloat = 5

        var screenHeight = UIScreen.main.bounds.height

        //store our results
        var pViewHeightResult:CGFloat = 0
        var heightResult:CGFloat = 0

        //when - execute code
        var res = getMovement(previousViewMinY: previousMinY, previousViewHeight: previousHeight, previousHeightBound: CGFloat(previousHeightBound), heightBound: CGFloat(heightBound), newLineYValue: &newYValue, viewHeight: CGFloat(lineHeight), followingMinY: screenHeight, previousViewNewHeight: &pViewHeightResult, newHeight: &heightResult)
 
        //then - assert result
        XCTAssert(res==false)
        XCTAssert(Int(pViewHeightResult) == Int(previousHeightBound))
        XCTAssert(Int(heightResult) == Int(screenHeight - previousHeightBound - lineHeight))
        
        
        //Test 2 - valid movement
        //given
        previousMinY = 20.0
        previousHeight = 40.0
        previousHeightBound = 20.0
        
        heightBound = 10
        newYValue = 50
        
        //when
        res = getMovement(previousViewMinY: CGFloat(previousMinY), previousViewHeight: CGFloat(previousHeight), previousHeightBound: previousHeightBound, heightBound: CGFloat(heightBound), newLineYValue: &newYValue, viewHeight: lineHeight, followingMinY: screenHeight, previousViewNewHeight: &pViewHeightResult, newHeight: &heightResult)
        
        //then
        XCTAssert(res==true)
        XCTAssert(Int(pViewHeightResult) == Int(30.0))
        XCTAssert(Int(heightResult) == Int(screenHeight - (newYValue + lineHeight)))
        print(Int(screenHeight - (newYValue + lineHeight)))
        
        
        //Test 3 - invalid - our other view is too small - previous overstretched
        //given
        heightBound = 40
        newYValue = screenHeight - 10
        
        //when
        res = getMovement(previousViewMinY: previousMinY, previousViewHeight: previousHeight, previousHeightBound: previousHeightBound, heightBound: CGFloat(heightBound), newLineYValue: &newYValue, viewHeight: lineHeight, followingMinY: screenHeight, previousViewNewHeight: &pViewHeightResult, newHeight: &heightResult)
        
        //then
        XCTAssert(res==false)
        XCTAssert(Int(pViewHeightResult)==Int(screenHeight - heightBound - lineHeight - previousMinY))
        XCTAssert(Int(heightResult)==Int(heightBound))
        
        //Test 4 - other views ontop and below
        //given
        var lowerScreenHeight: CGFloat = 500.0 // a view is below our previous and other view
        //when
        res = getMovement(previousViewMinY: previousMinY, previousViewHeight: previousHeight, previousHeightBound: previousHeightBound, heightBound: CGFloat(heightBound), newLineYValue: &newYValue, viewHeight: lineHeight, followingMinY: lowerScreenHeight, previousViewNewHeight: &pViewHeightResult, newHeight: &heightResult)
        //then
        XCTAssert(res==false)
        XCTAssert(Int(pViewHeightResult)==Int(lowerScreenHeight - heightBound - lineHeight - previousMinY))
        XCTAssert(Int(heightResult)==Int(heightBound))
    }

    func testLocationClass(){
        var location = Location.init(name: "Fairbanks", Kvf: 0.25, Kvt: 0.1, Kmf: 1.8, Kmt: 1.0, Cmf: 2000000, Cmt: 3000000, Cvf: 1000000, Cvt: 2000000, Hs: 0.3, Hv: 0.25, Cs: 500000, Tgs: 0.0, eta: 0.45, Ks: 0.15, Tair: -2, Aair: 17, ALT: 0)
        XCTAssertNotNil(location)
        
        location = Location.init(name: "", Kvf: 0, Kvt: 0, Kmf: 0, Kmt: 0, Cmf: 0, Cmt: 0, Cvf: 0, Cvt: 0, Hs: 0, Hv: 0, Cs: 0, Tgs: 0, eta: 0, Ks: 0, Tair: 0, Aair: 0, ALT: 0)
        XCTAssertNil(location)
    }
    
}
