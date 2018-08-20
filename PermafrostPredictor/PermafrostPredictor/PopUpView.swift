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
 
 Important: tags are used to keep track of the textfields when the submit button is pressed in the textFields array. This class is to be paired with a greyed out view with tag 100 for garbage collection.
 
 # Example Usage #
 ````
 var popup = PopUpView()
 popup.addTitle("Enter Data")
 popup.addLabels("Temperature", "Snow Depth")
 
 //create a greyed out view to go underneath so user knows this popup is active
 addGreyedOutView()
 self.view.addSubview(popup)
 ````
 
 */
class PopUpView: UIView{
    //keep track of the current position
    private var currentX:CGFloat = 0
    private var currentY:CGFloat = 20
    private var textFields = [UITextField]() //Keep track of the text fields for when
                          //the submit button is pressed
    private var padding: CGFloat = 20 //padding added to the sides of the text box (text not filling entire space)
    //function to call when a submit button is added. Intended to "callback" the user's provided function
    private var submitButtoncallback = {(dict: [Int: String])->Void in /*do nothing yet */}

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
    
/**
     Sets the background color of the popup.
     
     -parameter color: An UIColor object.
     # Usage Example: #
     ````
     var popup = PopUpView()
     popup.setBackGroundColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0))
     ````
 */
    //user can set the textbox's background color
    func setBackGroundColor(color: UIColor){
        self.backgroundColor = color
    }
    
/**
     Adds a submit button to the view. The button added is a button that closes the view and
        accepts the changes. This is the only supported button, meant to use once.
     
     -parameter buttonText: The text that will appear on the button.
     -parameter callback: The function that will be called upon the button being pressed. This isn't javascript, so the function is limited to a dictionary for input and a void output.
     
     # Usage Example: #
     ````
     func buttonPressed(dict: [Int: String]){
        //do something
     }
     popup.addButton("Submit", buttonPressed)
     ````
*/
    //Add a button to the view.
    func addButton(buttonText: String, callback: @escaping (_ textFields: [Int: String])->Void){
        
        //give extra space on the sides of the button by making it have a big initial text
        let button = UIButton()
        button.setTitle("Placeholder", for: .normal)
        button.sizeToFit()
        //set the actual button text
        button.setTitle(buttonText, for: .normal)

        //save the user's call back function - we will call it when the button is pressed
        submitButtoncallback = callback
        //add our callback to the button to remove the view & call the user's callback
        button.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)

        //calculate the space evenly to center the button
        let space = self.frame.width - button.frame.width
        let pad = space/2
        
        //place the button in the view
        button.frame.origin = CGPoint(x: currentX + pad, y: currentY)
        //update the current y position for the next element
        currentY += padding + button.frame.height
        
        //make the button rounded
        button.layer.cornerRadius = 10
        //make the text white and the button blue
        button.setTitleColor(UIColor(white: 1, alpha: 1), for: UIControlState.normal)
        button.backgroundColor = UIColor(red: 11/255, green: 181/255, blue: 1, alpha: 1)
        
        //An animation so the user knows the button was pressed. (Turns grey)
        button.addTarget(self, action: #selector(buttonHold), for: .touchDown)
        
        //add it to our popup view
        self.addSubview(button)
    }
    
/**
     Adds 2 labels in the same row to the popup view. (side by side)
     
     -parameter text: The text for the left label.
     -parameter text2: The text for the right label.
     
     # Usage Example: # 
*/
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
    
    func addTitle(title: NSMutableAttributedString) {
        //make it a label
        let titleLabel = UILabel()
        
        //make text appear all on one line
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        titleLabel.attributedText = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.sizeToFit()
        
        titleLabel.tag = 1000 //is a title - for redrawing purposes
        
        
        //find the spacing needed to center the text
        let xSpacing = (self.frame.width - titleLabel.frame.width)/2
        //set the position in the view
        titleLabel.frame.origin = CGPoint(x: xSpacing + currentX, y: currentY)
        currentY += padding + titleLabel.frame.height
        
        //add to view
        self.addSubview(titleLabel)
    }
    //Add a title (label) centered in view
    func addTitle(title: String){
        //make it a label
        let titleLabel = UILabel()
        
        //make text appear all on one line
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.sizeToFit()

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
    
    @objc private func submitButtonPressed(){
        //do callback
        submitButtoncallback(getValues())
        //delete popup view
        exit()
    }
    
    @objc private func buttonHold(sender: UIButton){
        sender.backgroundColor = .gray
    }
    
    //resizes the view to contain the elements inside, up to the screen size
    func resizeView(){
        if(self.subviews.count == 0){
            return // we have no views to resize
        }
        
        //find out how big the views are
        var totalHeight:CGFloat = 0
        var maxWidth:CGFloat = 0
        
        for subview in self.subviews {
            if(subview.frame.width > maxWidth){
                maxWidth = subview.frame.width
            }
        }
        
        //add the spacing between elements
        totalHeight = currentY

        //see if textfields are longer than the maxwidth element
        if(textFields.count > 0 && textFields[0].frame.width * 2 > maxWidth){
            maxWidth = textFields[0].frame.width * 2
        }
        
        //resize the popup appropriately
        var newWidth = maxWidth + (padding * 4)
        var newHeight = totalHeight + (padding) //padding is included in currentY as views are added
        
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
        if let greyView = self.superview?.viewWithTag(100) {
            greyView.removeFromSuperview()
        }
        //remove self
        self.removeFromSuperview()
    }

}
