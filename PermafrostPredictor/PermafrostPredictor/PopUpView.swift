//
//  PopUpView.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 5/30/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import Foundation
import UIKit

/**
 Class PopUpView: inherits from UIView. A class for an easy popupbox which can contain titles, labels, textfields, and a submit button. Titles and buttons are one column while the labels and fields are two columns. ELements are automatically centered.
 
 # Example Usage #
 ````
 var popup = PopUpView()
 popup.addTitle("Enter Data")
 popup.addLabels("Temperature", "Snow Depth")
 ````
 
 */
class PopUpView: UIView{
    //keep track of the current position
    var currentX:CGFloat = 0
    var currentY:CGFloat = 20
    var textFields = [UITextField]() //Keep track of the text fields for when
                          //the submit button is pressed
    var padding: CGFloat = 20
    
    //Initialization
    required init(){
        //Have the popup's size depend on the screen's
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        //set view height and width ahead of time for easier spacing
        super.init(frame: CGRect(origin: CGPoint(x: (screenWidth - screenWidth/2)/2, y: (screenHeight - screenHeight/2)/2), size: CGSize(width: screenWidth/2  , height: screenHeight/2)))
        
        //round the edges of the view
        self.layer.cornerRadius = 10
        
        //make the view white by default
        self.backgroundColor = UIColor(white: 1, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setBackGroundColor(color: UIColor){
        self.backgroundColor = color
    }
    
    //Add a button to the view.
    func addButton(button: UIButton){
        
        
        let space = self.frame.width - button.frame.width
        let pad = space/2
        
        button.frame.origin = CGPoint(x: currentX + pad, y: currentY)
        currentY += padding + button.frame.height
        
        //set the button color
        button.backgroundColor = .black
        //set the button to be rounded
        button.layer.cornerRadius = 10
        
        self.addSubview(button)
    }
    
    //add 2 labels side by side to the view
    func addLabels(text: String, text2: String){
        let label = UILabel()
        label.text = text
        label.sizeToFit()
        
        let label2 = UILabel()
        label2.text = text2
        label2.sizeToFit()
        
        //get the spacing needed to center the labels
        let space = self.frame.width - label.frame.width - label2.frame.width
        let pad = space/3 
        
        //place in view at x and y
        label.frame.origin = CGPoint(x: pad, y: currentY)
        label2.frame.origin = CGPoint(x: pad * 2 + label.frame.width, y: currentY )
        //update y pos
        currentY+=padding + label.frame.height
        
        //add to view
        self.addSubview(label)
        self.addSubview(label2)
        
    }
    
    //Add a title (label) centered in view
    func addTitle(title: String){
        //make it a label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        //find the spacing needed to center the text
        let xSpacing = (self.frame.width - titleLabel.frame.width)/2
        //set the position in the view
        titleLabel.frame.origin = CGPoint(x: xSpacing + currentX, y: currentY)
        currentY += padding + titleLabel.frame.height
        
        //add to view
        self.addSubview(titleLabel)
    }
    
    //Add 2 textfields side by side, centered in view
    func addTextFields(defaultText1: String, defaultText2: String, outputTag1: Int, outputTag2: Int){
        //create textfields
        let textField = UITextField()
        textField.text = defaultText1
        textField.sizeToFit()
        textField.tag = outputTag1
        
        let textField2 = UITextField()
        textField2.text = defaultText2
        textField2.sizeToFit()
        textField2.tag = outputTag2
        
        //find spacing
        let space = self.frame.width - textField2.frame.width - textField.frame.width
        let pad = space/3
        
        textField.frame.origin = CGPoint(x: currentX + pad, y: currentY)
        textField2.frame.origin = CGPoint(x: currentX + pad * 2 + textField.frame.width, y: currentY)
        //prepare the Y for next element
        currentY+=padding + textField.frame.height
        
        //save textfields in array for accessing their data when users are done entering
        textFields.append(textField)
        textFields.append(textField2)
        
        //add to view
        self.addSubview(textField)
        self.addSubview(textField2)
    }
    
    //return a dictionary containing the text field's values as strings & their corresponding tags as keys 
    func getValues()->[Int: String]{
        var dict: [Int: String] = [:]
        for t in textFields{
            dict[t.tag] = t.text
        }
        return dict
    }

}
