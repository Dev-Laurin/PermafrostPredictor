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
    var submitButtoncallback = {(dict: [Int: String])->Void in /*do nothing yet */}

    //Initialization
    required init(){
        //Have the popup's size depend on the screen's
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        //have popup be 75% of screen size
        let popUpHeight = screenHeight * 0.75
        let popUpWidth = screenWidth * 0.75
        //set view height and width ahead of time for easier spacing
        super.init(frame: CGRect(origin: CGPoint(x: (screenWidth - popUpWidth)/2, y: (screenHeight - popUpHeight)/2), size: CGSize(width: popUpWidth  , height: popUpHeight)))
        
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
    func addButton(buttonText: String, callback: @escaping (_ textFields: [Int: String])->Void){
        
        //give extra space on the sides of the button
        let button = UIButton()
        button.setTitle("Placeholder", for: .normal)
        button.sizeToFit()
        button.setTitle(buttonText, for: .normal)
        
        submitButtoncallback = callback
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)

        let space = self.frame.width - button.frame.width
        let pad = space/2
        
        button.frame.origin = CGPoint(x: currentX + pad, y: currentY)
        currentY += padding + button.frame.height
        


        //set the button to be rounded
        button.layer.cornerRadius = 10
         button.setTitleColor(UIColor(white: 1, alpha: 1), for: UIControlState.normal)
        button.backgroundColor = UIColor(red: 11/255, green: 181/255, blue: 1, alpha: 1)
        
        //so user knows it was pressed
        button.addTarget(self, action: #selector(buttonHold), for: .touchDown)
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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.tag = 1000 //is a title - for redrawing purposes
        
        //find the spacing needed to center the text
        let xSpacing = (self.frame.width - titleLabel.frame.width)/2
        //set the position in the view
        titleLabel.frame.origin = CGPoint(x: xSpacing + currentX, y: currentY)
        currentY += padding + titleLabel.frame.height
        
        //add to view
        self.addSubview(titleLabel)
    }
    
    func addTextField(text: String, tag: Int){
        let textfield = UITextField()
        textfield.text = "enter here"
        textfield.sizeToFit()
        textfield.text = text
        textfield.tag = tag
        
        textfield.textAlignment = .center
        textfield.layer.borderColor = UIColor.black.cgColor
        textfield.layer.borderWidth = 1
        textfield.layer.cornerRadius = 5
        
        let space = self.frame.width - textfield.frame.width
        let pad = space/2
        
        textfield.frame.origin = CGPoint(x: currentX + pad, y: currentY)
        currentY += textfield.frame.height + padding
        
        textFields.append(textfield)
        
        self.addSubview(textfield)
    }
    
    //Add 2 textfields side by side, centered in view
    func addTextFields(text: String, text2: String, outputTag1: Int, outputTag2: Int){
        
        //create textfields
        let textField = UITextField()
        textField.text = "enter here"
        textField.sizeToFit()
        textField.text = String(describing: text)
        textField.tag = outputTag1
        textField.textAlignment = .center
        
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        
        let textField2 = UITextField()
        textField2.text = "enter here"
        textField2.sizeToFit()
        textField2.text = text2
        textField2.tag = outputTag2
        textField2.textAlignment = .center
        
        textField2.layer.borderColor = UIColor.black.cgColor
        textField2.layer.borderWidth = 1
        textField2.layer.cornerRadius = 5
        
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
    
    @objc func submitButtonPressed(){
        //do callback
        submitButtoncallback(getValues())
        //delete popup view
        exit()
    }
    
    @objc func buttonHold(sender: UIButton){
        sender.backgroundColor = .gray
    }
    
    //resizes the view to contain the elements inside, up to the screen size
    func resizeView(){
        
        //find out how big the views are
        var totalHeight:CGFloat = 0
        var maxWidth:CGFloat = 0
        
        for subview in self.subviews {
            totalHeight += subview.frame.height
            if(subview.frame.width > maxWidth){
                maxWidth = subview.frame.width
            }
        }
        
        //see if textfields are longer than the maxwidth element
        if(textFields[0].frame.width * 2 > maxWidth){
            maxWidth = textFields[0].frame.width * 2
        }
        
        //resize the popup appropriately
        var newWidth = maxWidth + (padding * 4)
        var newHeight = totalHeight + (padding * 4)
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        //bound the view to grow to screen size only
        if(newWidth > screenWidth){
            newWidth = screenWidth
        }
        
        if(newHeight > screenHeight){
            newHeight = screenHeight
        }
        
        //resize
        let newX = (screenWidth - newWidth)/2
        let newY = (screenHeight - newHeight)/2
        self.frame = CGRect(origin: CGPoint(x: newX, y: newY), size: CGSize(width: newWidth, height: newHeight))
        
        //fix x values of elements inside
        for index in 0..<self.subviews.count {
            
            let oldY = self.subviews[index].frame.origin.y
            let availSpacing = self.frame.width - self.subviews[index].frame.width
            let spacing = availSpacing/2
            self.subviews[index].frame.origin = CGPoint(x: spacing, y: oldY)
            
            if(index>0){
                //textfields and labels are doubled up - make sure it doesn't effect the titles
                if((self.subviews[index-1] is UITextField && self.subviews[index] is UITextField) || (self.subviews[index-1] is UILabel && self.subviews[index] is UILabel && self.subviews[index-1].tag != 1000 && self.subviews[index].tag != 1000)){
                    //we are the second uitextfield or uilabel, change x accordingly
                    let totalWidth = self.subviews[index-1].frame.width + self.subviews[index].frame.width
                    let totalSpacing = self.frame.width - totalWidth
                    let spacing = totalSpacing/3

                    
                    //set the x of the side-by-side views
                    self.subviews[index-1].frame.origin = CGPoint(x: spacing, y: self.subviews[index-1].frame.origin.y)
                    self.subviews[index].frame.origin = CGPoint(x: (spacing * 2) + self.subviews[index-1].frame.width, y: self.subviews[index].frame.origin.y)
 
                }
            }
        }

    }
    
    //popup is done - exit
    func exit(){
        //remove greyed out view
        self.superview?.viewWithTag(100)?.removeFromSuperview()
        //remove self
        self.removeFromSuperview()
    }

}
