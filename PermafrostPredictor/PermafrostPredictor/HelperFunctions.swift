//
//  HelperFunctions.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 4/25/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import Foundation
import UIKit

/**
 Tests whether objects intersect with a given label.
 
 - parameter newY: The y value of the label we have to check against the other objects in the array.
 - parameter label: The UILabel that we are checking intersects any object in our array.
 - parameter frames: An array of object frames.
 
 # Example Usage: #
 ````
 if(intersects(newY: ourLabel.frame.minY, label: ourLabel, frames: [label1.frame, label2.frame]){
    print("Intersects!")
 }
 ````
 */
func intersects(newY: CGFloat, label: UILabel, frames: [CGRect])->Bool{
    let maxY = newY + label.frame.height
    for f in frames {
        if (maxY > f.minY && newY < f.minY) || (newY <= f.maxY && maxY >= f.maxY){
            //it intersects
            return true
        }
    }
    return false
}

/**
 Given a height, get the corresponding unit value according to the maximum value to maximum height ratio. Meant for positive numbers, with maxHeight != 0.
 
 - parameter maxHeight: The maximum height the view can have.
 - parameter maxValue: The maximum value.
 - parameter newHeight: The new height of the view.
 - parameter minValue: The minimum value.
 
 # Usage Example: #
 ````
 let result = turnHeightMovementIntoUnits(maxHeight: 100.0, maxValue: 5.0, newHeight: 50.0, minValue: 0.0)
 //Result == 2.5
 ````
 */
func turnHeightMovementIntoUnits(maxHeight: CGFloat, maxValue: CGFloat, newHeight: CGFloat, minValue: CGFloat)->CGFloat{
    return (newHeight * (maxValue/maxHeight)) + minValue
}

/**
 Get the value/unit at the given height of the view.
 
 - parameter topAverageValue: The value where the switch in the increase/decrease rate changes.
 - parameter maxValue: The maximum value.
 - parameter maxHeight: The maximum height of the view.
 - parameter newHeight: The new height of the view.
 - parameter percentage: The percentage of the height where the value rate changes.
 
 # Usage Example: #
 ````
 var result = getUnits(topAverageValue: 1.0, maxValue: 5.0, maxHeight: maxSnowHeight, newHeight: newImageViewHeight, percentage: 0.66)
 ````
 */
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

/**
 Get the corresponding view height given a value and the max height max value ratio.
 
 - parameter value: The unit/value.
 - parameter maxHeight: The maximum height the view can be.
 - parameter maxValue: The maximum value the view can be.
 - parameter minHeight: The minimum height the view has to be.
 - parameter minValue: The minimum value.
 
 # Usage Example: #
 ````
 let result = turnUnitsIntoHeight(value: 1.0, maxHeight: 500, maxValue: 5.0, minHeight: 0.0, minValue: 0.0)
 //Result == 100
 ````
 */
func turnUnitsIntoHeight(value: CGFloat, maxHeight: CGFloat, maxValue: CGFloat, minHeight: CGFloat, minValue: CGFloat)->CGFloat{
    return ((value - minValue) * (maxHeight/maxValue)) + minHeight
}

/**
 Returns the new height of the view given the corresponding unit and max height / max unit ratio.
 
 - parameter unit: The value.
 - parameter maxHeight: The maximum height of the view.
 - parameter maxValue: The maximum value that view can have.
 - parameter percentage: The percentage of the height where the value increase/decrease changes. For example: Perhaps most values appear between 0 and 1, so to make things easier for the user these values don't change as much with movement, however 1 to 5 does.
 - parameter topAverageValue: The value that the value increase/decrease changes at. As in the previous example above in the percentage parameter description, this value would be 1.
 
 # Usage Example: #
 ````
 var unit = getUnits(topAverageValue: 1.0, maxValue: 5.0, maxHeight: maxSnowHeight, newHeight: newHeight, percentage: 0.66)
 ````
 */
func getHeightFromUnits(unit: CGFloat, maxHeight: CGFloat, maxValue: CGFloat, percentage: CGFloat, topAverageValue: CGFloat )->CGFloat{
    
    var newHeight: CGFloat = 0.0
    let heightAtSwitch = maxHeight * percentage
    
    //In the lower section of height
    if(unit <= topAverageValue && topAverageValue > 0){
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
 var newLineYValue = newY
 let previousView = skyView

 let skyViewHeightBound: CGFloat = sunView.frame.maxY + tempLabel.frame.height + padding/2
 let heightBound: CGFloat = 0.0
 var newImageViewHeight = staticLineGround.frame.minY - (newLineYValue + view.frame.height)
 
 var previousViewHeight: CGFloat = (previousView?.frame.height)!
 
 let validMovement = getMovement(previousViewMinY: skyView.frame.minY, previousViewHeight: skyView.frame.height, previousHeightBound: skyViewHeightBound, heightBound: heightBound, newLineYValue: &newLineYValue, viewHeight: view.frame.height, followingMinY: staticLineGround.frame.minY, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)
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
 Given a CGFloat and a format, return a string of the number rounded to the given place.
 
 - parameter num: A CGFloat to be rounded.
 - parameter format: A String in the given form '.1' which represents how many decimal places to round.
 
 # Usage Example: #
 ````
 var temp = 4.5654654
 temp = round(num: temp, ".2")
 //temp now is 4.57
 ````
 */
func round(num: CGFloat, format: String)->CGFloat{
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
 let font = UIFont(name: "Helvetica", size: 20)!
 let smallFont = UIFont(name: "Helvetica", size: 10)! //we want this smaller
 let s = "X" //We want X_t with t subscripted
 let stringToSubscript = "t"
 var result = subscriptTheString(str: s, toSub: stringToSubscript, strAtEnd: "", bigFont: font,  smallFont: smallFont)
 ````
 
 # Strategy from: #
 https://stackoverflow.com/questions/29225779/how-to-use-subscript-and-superscript-in-swift#31125169
 */
func subscriptTheString(str: String, toSub: String, strAtEnd: String, bigFont: UIFont, smallFont: UIFont)->NSMutableAttributedString{
    let subscriptedString = NSMutableAttributedString(string: str+toSub+strAtEnd, attributes: [.font: bigFont])
    subscriptedString.setAttributes([.font: smallFont, .baselineOffset:-5], range: NSRange(location: str.count, length: toSub.count))
    return subscriptedString
}

/**
 Given a string, the string to be a superscript, and the fonts of both the strings, return an attributed string with the superscript (like raising to the power of).
 
 - parameter str: The string that is not superscripted.
 - parameter toSuper: The string that will be a superscript.
 - parameter strAtEnd: String that comes after superscript.
 - parameter bigFont: The font of the not superscripted string.
 - parameter smallFont: The font of the superscript.
 
 # Usage Example: #
 ````
 let font = UIFont(name: "Helvetica", size: 20)!
 let smallFont = UIFont(name: "Helvetica", size: 10)! //we want this smaller
 let s = "X" //We want X^2
 let stringToSuperscript = "2"
 var result = superscriptTheString(str: s, toSuper: stringToSuperscript, strAtEnd: "", bigFont: font,  smallFont: smallFont)
 ````
 
 # Strategy from: #
 https://stackoverflow.com/questions/29225779/how-to-use-subscript-and-superscript-in-swift#31125169
 */
func superscriptTheString(str: String, toSuper: String, strAtEnd: String, bigFont: UIFont, smallFont: UIFont)->NSMutableAttributedString {
    let superScriptedString = NSMutableAttributedString(string: str+toSuper+strAtEnd, attributes: [.font: bigFont])
    superScriptedString.setAttributes([.font: smallFont, .baselineOffset: 10], range: NSRange(location: str.count, length: toSuper.count))
    return superScriptedString
}

/**
 Given a view and a new X and Y coordinate values, return a view with the new origin. (This reduced typing.)
 
 - parameter view: UIView to re-draw.
 - parameter newX: New X coordinate for the view.
 - parameter newY: New Y coordinate for the view.
 
 # Usage Example: #
 ````
 var tempView = UIView()
 tempView = changeViewsYValue(view: tempView, newX: 50, newY: 50)
 ````
 */
func changeViewsYValue( view: UIView, newX: CGFloat, newY: CGFloat)->UIView{
    var rect = view.frame
    rect.origin = CGPoint(x: newX, y: newY)
    view.frame = rect
    
    return view
}
