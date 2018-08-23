//
//  HelperFunctions.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 4/25/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import Foundation
import UIKit

func turnHeightMovementIntoUnits(maxHeight: CGFloat, maxValue: CGFloat, newHeight: CGFloat, minValue: CGFloat)->CGFloat{
    return (newHeight * (maxValue/maxHeight)) + minValue
}

func getUnits(topAverageValue: CGFloat, maxValue: CGFloat, maxHeight: CGFloat, newHeight: CGFloat, percentage: CGFloat)->CGFloat{
    //Find out when the switch happens (what height)
    let heightAtSwitch = maxHeight * percentage
    var value: CGFloat = 0.0
    if(newHeight < heightAtSwitch){
        //we are in the average case
        value = turnHeightMovementIntoUnits(maxHeight: heightAtSwitch, maxValue: topAverageValue, newHeight: newHeight, minValue: value)
        
        if(value < 0.09){
            value = 0.0
        }
    }
    else{
        //we are not in the average
        value = turnHeightMovementIntoUnits(maxHeight: maxHeight - heightAtSwitch, maxValue: maxValue, newHeight: newHeight - heightAtSwitch, minValue: topAverageValue)
        if(value > maxValue){
            value = maxValue
        }
        
    }
    return value
}

func turnUnitsIntoHeight(value: CGFloat, maxHeight: CGFloat, maxValue: CGFloat, minHeight: CGFloat, minValue: CGFloat)->CGFloat{
    return ((value - minValue) * (maxHeight/maxValue)) + minHeight
}

func getHeightFromUnits(unit: CGFloat, maxHeight: CGFloat, maxValue: CGFloat, percentage: CGFloat, topAverageValue: CGFloat )->CGFloat{
    var newHeight: CGFloat = 0.0
    let heightAtSwitch = maxHeight * percentage
    //In the lower section of height
    if(unit <= topAverageValue){
        newHeight = turnUnitsIntoHeight(value: unit, maxHeight: heightAtSwitch, maxValue: topAverageValue, minHeight: 0.0, minValue: 0.0)
    }
    else {
        newHeight = turnUnitsIntoHeight(value: unit, maxHeight: maxHeight - heightAtSwitch, maxValue: maxValue, minHeight: heightAtSwitch, minValue: topAverageValue)
    }
    //make sure height is not greater than the max
    if(newHeight > maxHeight){
        newHeight = maxHeight
    }
    return newHeight
}

/**
    Given information about 2 views, this function gives you the new height of both the previous view and the current view, seperated by lineViews. This gives the correct new sizes so that the views still cover the parent view (one view shrink or grows the other.) This also calculates the heights in respect to given bounds (can't shrink beyond this... can't grow beyond that...). It returns true or false if the movement was valid or not (no bounds were hit).
 
 - parameter previousView: The view that is above the view you are moving / resizing on the screen.
 - parameter previousHeightBound: The minimum height the previous view can be. (So we don't shrink it to 0 if we don't want it to)
 - parameter heightBound: The minimum height the other view can be. So we don't overexpand the previous view.
 - parameter newLineYValue: The Y value of the line view we are moving. (UI has 2 views seperated by a line view. Line views are movable and resize the other views via this function.)
 - parameter view: The line view we are moving.
 - parameter followingMinY: The Y value of the view after our other view. (Previous view, other view, following view).
 - parameter previousViewNewHeight: A variable passed by reference to place the previous view's height that we calculate.
 - parameter newHeight: A variable passed by reference to hold the other view's height that we calculate.
 
 # Usage Example: #
 ````
 
 ````
 
*/
func getMovement(previousViewMinY: CGFloat, previousViewHeight: CGFloat, previousHeightBound: CGFloat, heightBound: CGFloat, newLineYValue: inout CGFloat, viewHeight: CGFloat, followingMinY: CGFloat, previousViewNewHeight: inout CGFloat, newHeight: inout CGFloat  )->Bool{
    
    //get our new height for our lower view
    var newImageViewHeight: CGFloat = followingMinY - (newLineYValue + viewHeight)
    
    //set the height of our previous view for computation
    var previousViewHeight: CGFloat = (previousViewHeight)
    
    //If the new Y value of the moving line would make the previous view too small 
    if(newLineYValue < (previousViewMinY + previousHeightBound)){
        //Set the Y value to go no further than the ending Y value
        previousViewHeight = previousHeightBound
        newLineYValue = (previousViewMinY) + previousViewHeight
        newImageViewHeight = followingMinY - newLineYValue - viewHeight
        
        newHeight = newImageViewHeight
        previousViewNewHeight = previousViewHeight
        
        return false //movement not valid
    }
        //our lower view is too small - set it to the minimum
    else if newImageViewHeight < heightBound {
        newImageViewHeight = heightBound
        newLineYValue = followingMinY - heightBound - viewHeight
        previousViewHeight = newLineYValue - (previousViewMinY)
        
        newHeight = newImageViewHeight
        previousViewNewHeight = previousViewHeight
        
        return false //movement not valid
    }
    else {
        //we can move that much
        previousViewHeight = newLineYValue - (previousViewMinY)
        
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
    let format = ".2"
    return NumberFormatter().number(from:(String(format: "%\(format)f", num))) as! CGFloat
}


func roundToTenths(num: CGFloat)->CGFloat{
    let format = ".1"
    return NumberFormatter().number(from:(String(format: "%\(format)f", num))) as! CGFloat
}
/*
func round(num: CGFloat, format: String)->CGFloat{
    return NumberFormatter().number(from:(String(format: "%\(format)f", num))) as! CGFloat
}*/

/**
 Given a CGFloat, return a string of the number rounded to the thousandths place.
 
 - parameter num: A CGFloat to be rounded.
 
 # Usage Example: #
 ````
 var temp = 3.2458
 temp = roundToHundredths(num: temp)
 //temp is now 3.246
 ````
 */
func roundToThousandths(num: CGFloat)->CGFloat{
    let format = ".3"
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

func superscriptTheString(str: String, toSuper: String, strAtEnd: String, bigFont: UIFont, smallFont: UIFont)->NSMutableAttributedString {
    let superScriptedString = NSMutableAttributedString(string: str+toSuper+strAtEnd, attributes: [.font: bigFont])
    superScriptedString.setAttributes([.font: smallFont, .baselineOffset: 10], range: NSRange(location: str.count, length: toSuper.count))
    return superScriptedString
}

func changeViewsYValue( view: UIView, newX: CGFloat, newY: CGFloat)->UIView{
    var rect = view.frame
    rect.origin = CGPoint(x: newX, y: newY)
    view.frame = rect
    
    return view
}

/**
 Converts celsius temperature to Kelvin.
 
 - parameter num: The number to convert.
 
 # Usage Example: #
 ````
 var tempInCelsius = 20.0
 var kelvin = convertToKelvin(tempInCelsius)
 ````
*/
func convertToKelvin(num: Double)->Double{
    return num + 273.15
}

