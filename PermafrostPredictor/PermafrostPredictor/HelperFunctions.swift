//
//  HelperFunctions.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 4/25/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import Foundation
import UIKit

 //getMovement(previousView: staticGroundLayer, previousHeightBound: 0.0, heightBound: groundLayerHeightBound, newLineYValue: &newLineYValue, view: view, followingMinY: screenHeight, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)

func getMovement(previousView: UIView, previousHeightBound: CGFloat, heightBound: CGFloat, newLineYValue: inout CGFloat, view: UIView, followingMinY: CGFloat, previousViewNewHeight: inout CGFloat, newHeight: inout CGFloat  )->Bool{
    
    var newImageViewHeight: CGFloat = followingMinY - (newLineYValue + view.frame.height)
    
    var previousViewHeight: CGFloat = (previousView.frame.height)
    
    //If the new Y value of the moving line would make the previous view too small 
    if(newLineYValue < (previousView.frame.minY + previousHeightBound)){
        //Set the Y value to go no further than the static ground image's ending Y value
        previousViewHeight = previousHeightBound
        newLineYValue = (previousView.frame.minY) + previousViewHeight
        newImageViewHeight = followingMinY - newLineYValue - view.frame.height
        
        newHeight = newImageViewHeight
        previousViewNewHeight = previousViewHeight
        
        return false //movement not valid
    }
        //set the bound
    else if newImageViewHeight < heightBound {
        newImageViewHeight = heightBound
        newLineYValue = followingMinY - heightBound - view.frame.height
        previousViewHeight = newLineYValue - (previousView.frame.minY)
        
        newHeight = newImageViewHeight
        previousViewNewHeight = previousViewHeight
        
        return false //movement not valid
    }
    else {
        //we can move that much
        previousViewHeight = newLineYValue - (previousView.frame.minY)
        
        newHeight = newImageViewHeight
        previousViewNewHeight = previousViewHeight
        
        return true //valid movement
    }
    
}

/**
 Turns the movement tracked by the device (how much the finger moved on the screen) into units we want for our UI. We don't want huge changes from really small gestures.
 
 - parameter movement: The translation, in gesture recognizer units. (Is a number, not a recognizer translation. So no .x or .y).
 
 # Usage Example: #
 ````
 var translated = translation.x
 var degrees = turnMovementIntoUnits(movement: translated)
 ````
 */
func turnMovementIntoUnits(movement: CGFloat)->CGFloat{
    //For every 5 units of movement translation, have our unit go up 1
    //Example: My finger swiped 25 movement in x direction, but I only want the temperature to change by 5

    let unitPerMovement:CGFloat = 1/5.0
    let units = unitPerMovement * movement
    return units
}

/**
 To handle the difference in x and y translation from the sun while panning to change temperature. This takes the translation point, finds the hypotenuse of the right triangle, and turns its value into a temperature degrees value.
 
 - parameter translation: The movement of the user's finger as given by a gesture recognizer.
 
 # Usage Example: #
 ````
 @IBAction func handleSkyGesture(recognizer: UIPanGestureRecognizer){
 let translation = recognizer.translation(in: self.view)
 
 //Get the movement difference in degrees
 var temp = turnTranslationIntoTemp(translation: translation)
 }
 ````
 */
func turnTranslationIntoTemp(translation: CGPoint)->CGFloat{
    //Find the vector magnitude of translation (hypotenuse of right triangle)
    let x = translation.x
    let y = translation.y
    var hypotenuse = x*x + y*y
    hypotenuse = hypotenuse.squareRoot()
    
    //Translate the vector magnitude (hypotenuse) of the difference in movement
    //into units of temperature
    return turnMovementIntoUnits(movement: hypotenuse)
}


/**
 This function, given an image, makes a copy of the image, crops it, and returns the new cropped image of the new width and height.
 
 - parameter image: A valid, croppable, UIImage.
 - parameter newWidth: The desired new width of the cropped image.
 - parameter newHeight: The desired new height of the cropped image.
 
 # Usage Example: #
 ````
 let image = UIImage(named: "testImage")
 var croppedWidth = 500
 var croppedHeight = 400
 var croppedImage = cropImage(image: image, newWidth: croppedWidth, newHeight: croppedHeight)
 ````
 */
func cropImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat)->UIImage{
    //Make the new rectangle
    let rect : CGRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: newHeight)
    //Do the crop
    let img = UIImage(cgImage: (image.cgImage?.cropping(to: rect))!)
    return img
}

/**
 Given a CGFloat, return a string of the number rounded to the hundredths place.
 
 - parameter num: A CGFloat to be rounded.
 
 # Usage Example: #
 ````
 var temp = 4.5654654
 temp = roundToHundredths(num: temp)
 //temp now is 4.56
 ````
 */
func roundToHundredths(num: CGFloat)->CGFloat{
    //Round to the Hundredths place, this is the format string
    let format = ".1"
    return NumberFormatter().number(from:(String(format: "%\(format)f", num))) as! CGFloat
}

func roundToThousandths(num: CGFloat)->CGFloat{
    let format = ".2"
    return NumberFormatter().number(from:(String(format: "%\(format)f", num))) as! CGFloat
}

/**
 Given a string, the string to be a subscript, and the fonts of both the strings, return an attributed string with the subscript.
 
 - parameter str: The string that is not subscripted
 - parameter toSub: The string that will be a subscript
 - parameter strAtEnd: String that comes after subscript
 - parameter bigFont: The font of the not subscripted string.
 - parameter smallFont: The font of the subscript.
 
 # Usage Example: #
 ````
 var font = UIFont(name: "Helvetica", size: 20)
 var smallFont = UIFont(name: "Helvetica", size: 10) //we want this smaller
 var s = X //We want X_t with t subscripted
 var stringToSubscript = t
 var result = subscriptTheString(s, stringToSubscript, font, smallFont)
 ````
 
 # Strategy from: #
 https://stackoverflow.com/questions/29225779/how-to-use-subscript-and-superscript-in-swift#31125169
 */
func subscriptTheString(str: String, toSub: String, strAtEnd: String, bigFont: UIFont, smallFont: UIFont)->NSMutableAttributedString{
    let subscriptedString = NSMutableAttributedString(string: str+toSub+strAtEnd, attributes: [.font: bigFont])
    subscriptedString.setAttributes([.font: smallFont, .baselineOffset:-5], range: NSRange(location: str.count, length: toSub.count))
    return subscriptedString
}

func changeViewsYValue( view: UIView, newX: CGFloat, newY: CGFloat)->UIView{
    var rect = view.frame
    rect.origin = CGPoint(x: newX, y: newY)
    view.frame = rect
    
    return view
}

