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
    var vc : ViewController! 
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        vc = storyboard.instantiateInitialViewController() as! ViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        let image = UIImage(named: "test")
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
        let img = UIImage(named: "test")
        imageView = UIImageView(image: img)
        imageView.image = cropImage(image: imageView.image!, newWidth: imageView.frame.width, newHeight: 20)
        imageView.frame = CGRect(origin: CGPoint(x: imageView.frame.minX, y: imageView.frame.minY), size: CGSize(width: (imageView.frame.width),height: 20))
        
        XCTAssert(imageView.image?.size.height == 20)
    }
    
    //test the getmovement helper function
    func testGetMovement(){
         //returns valid movement
        
        //gives the previous height, new height, and new Y value
        
        
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
        XCTAssert(roundToHundredths(num: 1.55555) == 1.6)
        XCTAssert(roundToHundredths(num: 0.05) == 0.1)
        XCTAssert(roundToHundredths(num: -3.356) == -3.4)
        XCTAssert(roundToHundredths(num: 1.22222) == 1.2)
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

    func testMatlabConvertedFunctions(){
        //test given by stakeholder - May 22, 2018
        XCTAssert(roundToThousandths(num: CGFloat(computePermafrost(Kvf: 0.25, Kvt: 0.1, Kmf: 1.8, Kmt: 1.0, Cmf: 2000000, Cmt: 3000000, Cvf: 1000000, Cvt: 2000000, Hs: 0.3, Hv: 0.25, Cs: 500000))) == 0.86)
    }
    
}
