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
    
    func testIfViewsHaveCorrectImages(){
        
<<<<<<< HEAD
    }
    
    func testcropImage(){
        //Test function
        let image = UIImage(named: "test")
        var imageView = UIImageView(image: image)
        imageView.image = vc.cropImage(image: imageView.image!, newWidth: imageView.frame.width, newHeight: 50)

=======
        //Test If the image is sized correctly
        let newImageSize : CGFloat = 50
        let image = UIImage(named: "test")
        let imageView = UIImageView(image: image)
        let newImage = vc.cropImage(image: imageView.image!, newWidth: imageView.frame.width, newHeight: newImageSize)
>>>>>>> d4a3041a6824f5f96b1d9f3545974db3b28309b7
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
        var img = UIImage(named: "test")
        imageView = UIImageView(image: img)
        imageView.image = vc.cropImage(image: imageView.image!, newWidth: imageView.frame.width, newHeight: 20)
        imageView.frame = CGRect(origin: CGPoint(x: imageView.frame.minX, y: imageView.frame.minY), size: CGSize(width: (imageView.frame.width),height: 20))
        
        XCTAssert(imageView.image?.size.height == 20)
    }
    
}
