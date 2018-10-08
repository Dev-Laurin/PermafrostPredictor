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
        vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController //as! ViewController
        vc.loadView()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        vc = nil
        super.tearDown()
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
    
    func testRound() {
        //Tenths
        //round up
        var num: CGFloat = 2.555
        XCTAssert(round(num: num, format: ".1") == 2.6)
        
        //round down
        num = 2.54
        XCTAssert(round(num: num, format: ".1") == 2.5)
        
        //Hundredths
        num = 1.55555
        XCTAssert(round(num: num, format: ".2") == 1.56)
        num = 0.05
        XCTAssert(round(num: num, format: ".2") == 0.05)
        num = -3.356
        XCTAssert(round(num: num, format: ".2") == -3.36)
        num = 1.22222
        XCTAssert(round(num: num, format: ".2") == 1.22)
        
        //Thousandths
        num = 1.7772
        XCTAssert(round(num: num, format: ".3") == 1.777)
        num = 0.05
        XCTAssert(round(num: num, format: ".3") == 0.05)
        num = -4.2323
        XCTAssert(round(num: num, format: ".3") == -4.232)
        num = 3.2347
        XCTAssert(round(num: num, format: ".3") == 3.235)
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
        
        let lineHeight: CGFloat = 5

        let screenHeight = UIScreen.main.bounds.height

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
        let lowerScreenHeight: CGFloat = 500.0 // a view is below our previous and other view
        //when
        res = getMovement(previousViewMinY: previousMinY, previousViewHeight: previousHeight, previousHeightBound: previousHeightBound, heightBound: CGFloat(heightBound), newLineYValue: &newYValue, viewHeight: lineHeight, followingMinY: lowerScreenHeight, previousViewNewHeight: &pViewHeightResult, newHeight: &heightResult)
        //then
        XCTAssert(res==false)
        XCTAssert(Int(pViewHeightResult)==Int(lowerScreenHeight - heightBound - lineHeight - previousMinY))
        XCTAssert(Int(heightResult)==Int(heightBound))
    }

    func testGetHeightFromUnits(){
        
        //Test Snow View above the average height
        let maxSnowHeight: CGFloat = 400.0
        var newHeight = getHeightFromUnits(unit: 2.5, maxHeight: maxSnowHeight, maxValue: 5.0, percentage: 0.66, topAverageValue: 1.0)
        var unit = getUnits(topAverageValue: 1.0, maxValue: 5.0, maxHeight: maxSnowHeight, newHeight: newHeight, percentage: 0.66)

        //can't compare floats easily == 2.5
        XCTAssert( 2.4 < unit && unit < 2.6 )
        
        //Test Snow below average height
        newHeight = getHeightFromUnits(unit: 0.5, maxHeight: maxSnowHeight, maxValue: 5.0, percentage: 0.66, topAverageValue: 1.0)
        unit = getUnits(topAverageValue: 1.0, maxValue: 5.0, maxHeight: maxSnowHeight, newHeight: newHeight, percentage: 0.66)
        //can't compare floats easily == 0.5
        XCTAssert( 0.4 < unit && unit < 0.6 )
        
        //Test Snow at average height
        newHeight = getHeightFromUnits(unit: 1.0, maxHeight: maxSnowHeight, maxValue: 5.0, percentage: 0.66, topAverageValue: 1.0)
        unit = getUnits(topAverageValue: 1.0, maxValue: 5.0, maxHeight: maxSnowHeight, newHeight: newHeight, percentage: 0.66)
        
        XCTAssert(newHeight == maxSnowHeight*0.66)
        //can't compare floats easily == 1.0
        XCTAssert( 0.9 < unit && unit < 1.1 )
        
        //Test Organic above
        let maxOrganicHeight: CGFloat = 500.0
        newHeight = getHeightFromUnits(unit: 0.25, maxHeight: maxOrganicHeight, maxValue: 0.25, percentage: 0, topAverageValue: 0.0)
        unit = getUnits(topAverageValue: 0, maxValue: 0.25, maxHeight: maxOrganicHeight, newHeight: newHeight, percentage: 0)
        
        XCTAssert(newHeight == maxOrganicHeight)
        //can't compare floats easily == 0.25
        XCTAssert( 0.24 < unit && unit < 0.26 )
        
        //Test Organic below
        newHeight = getHeightFromUnits(unit: 0.22, maxHeight: maxOrganicHeight, maxValue: 0.25, percentage: 0, topAverageValue: 0.0)
        unit = getUnits(topAverageValue: 0, maxValue: 0.25, maxHeight: maxOrganicHeight, newHeight: newHeight, percentage: 0)
        
        //can't compare floats easily == 0.22
        XCTAssert( 0.21 < unit && unit < 0.23 )
    
        //Test Organic at 0
        newHeight = getHeightFromUnits(unit: 0, maxHeight: maxOrganicHeight, maxValue: 0.25, percentage: 0.66, topAverageValue: 1.0)
        unit = getUnits(topAverageValue: 0, maxValue: 0.25, maxHeight: maxOrganicHeight, newHeight: newHeight, percentage: 0)
        
        XCTAssert(newHeight == 0.0)
        //can't compare floats easily == 0
        XCTAssert( -0.1 < unit && unit < 0.1 )
        
    }
    
    func testIntersects(){
        let label = UILabel()
        label.frame = CGRect(origin: CGPoint(x: 0.0, y: 44.0), size: CGSize(width: 40, height: 20))
        let label1 = UILabel()
        label1.frame = CGRect(origin: CGPoint(x: 0.0, y: 40.0), size: CGSize(width: 40, height: 20))
        let label2 = UILabel()
        label2.frame = CGRect(origin: CGPoint(x: 0.0, y: 100.0), size: CGSize(width: 40, height: 20))
        
        //Intersects
        XCTAssert(intersects(newY: 44.0, label: label, frames: [label1.frame, label2.frame]))
        //Doesn't intersect
        XCTAssert(!intersects(newY: 44.0, label: label, frames: [label2.frame]))
    }
    
    func testHeightMovementIntoUnits(){
        
        let result = turnHeightMovementIntoUnits(maxHeight: 100.0, maxValue: 5.0, newHeight: 50.0, minValue: 0.0)
        XCTAssert(2.4 < result && result < 2.6)
        
        XCTAssert(turnHeightMovementIntoUnits(maxHeight: 0.0, maxValue: 0.0, newHeight: 0.0, minValue: 0.0).isNaN)
    }
    
    func testTurnUnitsIntoHeight() {
       let result = turnUnitsIntoHeight(value: 1.0, maxHeight: 500, maxValue: 5.0, minHeight: 0.0, minValue: 0.0)
        
        XCTAssert(99.0 < result && result < 101.0)
        
        let res = turnUnitsIntoHeight(value: 1.0, maxHeight: 0, maxValue: 0.0, minHeight: 0.0, minValue: 0.0)
        XCTAssert(res.isNaN)
    }
    
    func testSubscriptTheString() {
        //test to see it doesn't crash -
        let font = UIFont(name: "Helvetica", size: 20)!
        let smallFont = UIFont(name: "Helvetica", size: 10)! //we want this smaller
        let s = "X" //We want X_t with t subscripted
        let stringToSubscript = "t"
        _ = subscriptTheString(str: s, toSub: stringToSubscript, strAtEnd: "", bigFont: font,  smallFont: smallFont)
        XCTAssert(true) // no crash - count it as a test passed
    }
    
    func testSuperscriptTheString() {
        let font = UIFont(name: "Helvetica", size: 20)!
        let smallFont = UIFont(name: "Helvetica", size: 10)! //we want this smaller
        let s = "X" //We want X^2
        let stringToSuperscript = "2"
        _ = superscriptTheString(str: s, toSuper: stringToSuperscript, strAtEnd: "", bigFont: font,  smallFont: smallFont)
    }
    
    func testFindMaxFontForLabel(){
        //font based off screen size
        let screenWidth: CGFloat = 500 - 20 //for padding
        var label = UILabel()
        label.text = "Hello"
        label.font = label.font.withSize(1)
        label.sizeToFit()
        var fontSize1 = label.frame.width
        let size = screenWidth/fontSize1
        
        XCTAssert(findMaxFontForLabel(label: label, maxSize: screenWidth) == size)
        
        //Empty string
        label.text = ""
        label.sizeToFit()
        fontSize1 = label.frame.width
        XCTAssert(findMaxFontForLabel(label: label, maxSize: screenWidth) == 0.0)
        
        label = UILabel()
        XCTAssert(findMaxFontForLabel(label: label, maxSize: screenWidth) == 0.0)
    }
    
    //MARK: matlabConvertedFunctions.swift
    //test the permafrost calculating functions
    func testMatlabConvertedFunctions(){
        //test given by stakeholder - May 22, 2018
        var temp: Double = 0
        var temp2: Double = 0
        XCTAssert(round(num: CGFloat(computePermafrost(Kvf: 0.25, Kvt: 0.1, Kmf: 1.8, Kmt: 1.0, Cmf: 2000000, Cmt: 3000000, Cvf: 1000000, Cvt: 2000000, Hs: 0.3, Hv: 0.25, Cs: 500000, magt: &temp, tTemp: -2, aTemp: 17, eta: 0.45, Ks: 0.15, Tvs: &temp2)), format: ".3") == 0.86)
        
        //Test with units that cause NaN
        XCTAssert(!computePermafrost(Kvf: 0.25, Kvt: 0.1, Kmf: 1.8, Kmt: 1.0, Cmf: 2000000, Cmt: 3000000, Cvf: 1000000, Cvt: 2000000, Hs: 0.3, Hv: 0.25, Cs: 500000, magt: &temp, tTemp: -25, aTemp: 25, eta: 0.45, Ks: 0.15, Tvs: &temp2).isNaN)
        
    }
    
    //MARK: PopUpView.swift
    //testing the popup class
    func testPopupView(){
        //test the default size
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        //get the navigation bar height
        let barHeight: CGFloat = 0.0
        
        //popup should initially be 75% of the screen - until resizing
        let height = screenHeight * 0.75
        let width = screenWidth * 0.75
        let popup = PopUpView()
        XCTAssert(popup.frame.width == width)
        XCTAssert(popup.frame.height == height)
        
        //resize an empty popup
        popup.resizeView(navBarHeight: barHeight)
        XCTAssert(popup.frame.width == width)
        XCTAssert(popup.frame.height == height)
        
        //call the non-existant callback? - inaccessable - pass
        //popup.submitButtoncallback([1: "test"])
        
        //resize a popup with a title
        popup.addTitle(title: "test")
        popup.resizeView(navBarHeight: barHeight)
        
        //add a button - test callback
        popup.addButton(buttonText: "submit", callback: buttonPressed)
        
        //calling button pressed functions early - unaccessable -pass
        //popup.submitButtonPressed()
        
        
        //Test Longer than Screen Width & Height
        popup.addLabels(text: "Ratione sint sit est nisi iusto labore voluptas facilis. Quo ut ea est ut quaerat. Optio dolorem quibusdam accusamus. Velit aut at repudiandae omnis est nobis perspiciatis. Qui asperiores explicabo aliquid animi. Quam et natus quasi deleniti suscipit", text2: "test")
        XCTAssert(popup.frame.width <= screenWidth)
        XCTAssert(popup.frame.height <= screenHeight)
        
        //Add too much text for a button
        popup.addButton(buttonText: "Ratione sint sit est nisi iusto labore voluptas facilis. Quo ut ea est ut quaerat. Optio dolorem quibusdam accusamus. Velit aut at repudiandae omnis est nobis perspiciatis. Qui asperiores explicabo aliquid animi. Quam et natus quasi deleniti suscipit", callback: buttonPressed)
        
        //add a negative tag
        popup.addTextField(text: "Ratione sint sit est nisi iusto labore voluptas facilis. Quo ut ea est ut quaerat. Optio dolorem quibusdam accusamus. Velit aut at repudiandae omnis est nobis perspiciatis. Qui asperiores explicabo aliquid animi. Quam et natus quasi deleniti suscipit", tag: -2)
        
        //test if textfields added are recorded
        let popup2 = PopUpView()
        popup2.addTextField(text: "test", tag: 0)
        var vals = popup2.getValues()
        XCTAssert(vals[0] == "test")
        
        popup.exit()
    }
    
    //for the popup class test - the button callback
    func buttonPressed(dict: [Int: String]){
        //nothing - doesn't get called due to lack of UI
    }
    
    //MARK: Location.swift
    func testLocationClass(){
        var location = Location.init(name: "Fairbanks", Kvf: 0.25, Kvt: 0.1, Kmf: 1.8, Kmt: 1.0, Cmf: 2000000, Cmt: 3000000, Cvf: 1000000, Cvt: 2000000, Hs: 0.3, Hv: 0.25, Cs: 500000, Tgs: 0.0, eta: 0.45, Ks: 0.15, Tair: -2, Aair: 17, ALT: 0, Tvs: 0.0)
        XCTAssertNotNil(location)
        
        location = Location.init(name: "", Kvf: 0, Kvt: 0, Kmf: 0, Kmt: 0, Cmf: 0, Cmt: 0, Cvf: 0, Cvt: 0, Hs: 0, Hv: 0, Cs: 0, Tgs: 0, eta: 0, Ks: 0, Tair: 0, Aair: 0, ALT: 0, Tvs: 0.0)
        XCTAssertNil(location)
        
    }
    
}
