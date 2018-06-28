//
//  PopUpView.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 5/30/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import Foundation
import UIKit

class PopUpView: UIView{
 //   var view = UIView()
    //keep track of the current position
    var currentX:CGFloat = 0
    var currentY:CGFloat = 20
    var firstColumn:Bool = true //the current column tracking
    var textFields = [UITextField]() //Keep track of the text fields for when
                          //the submit button is pressed
    var padding: CGFloat = 20
    var widestItemWidth: CGFloat = 0
    //Initialization
    //Need the view's height, width
    required init(){
        var screenHeight = UIScreen.main.bounds.height
        var screenWidth = UIScreen.main.bounds.width
        super.init(frame: CGRect(origin: CGPoint(x: (screenWidth - screenWidth/2)/2, y: (screenHeight - screenHeight/2)/2), size: CGSize(width: screenWidth/2  , height: screenHeight/2)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setBackGroundColor(color: UIColor){
        self.backgroundColor = color
    }
    func addButton(button: UIButton){
        button.sizeToFit()
        button.frame.origin = CGPoint(x: padding, y: currentY + button.frame.height + padding)
        
        self.addSubview(button)
    }
    
    //add 2 labels side by side to the view
    func addLabels(text: String, text2: String){
        var label = UILabel()
        label.text = text
        label.sizeToFit()
        
        var label2 = UILabel()
        label2.text = text2
        label2.sizeToFit()
        
        //get the spacing needed to center the labels
        var space = self.frame.width - label.frame.width - label2.frame.width
        var pad = space/3 
        
        label.frame.origin = CGPoint(x: pad, y: currentY)
        label2.frame.origin = CGPoint(x: pad * 2 + label.frame.width, y: currentY )
        currentY+=padding + label.frame.height
        
        self.addSubview(label)
        self.addSubview(label2)
        
    }
    
    func addTitle(title: String){
        //make it a label
        var titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        //find the spacing needed to center the text
        var xSpacing = (self.frame.width - titleLabel.frame.width)/2
        //set the position in the view
        titleLabel.frame.origin = CGPoint(x: xSpacing + currentX, y: currentY)
        currentY += padding + titleLabel.frame.height
        
        //add to view
        self.addSubview(titleLabel)
    }
    func addTextFields(defaultText1: String, defaultText2: String){
        var textField = UITextField()
        textField.text = defaultText1
        textField.sizeToFit()
        
        var textField2 = UITextField()
        textField2.text = defaultText2
        textField2.sizeToFit()
        
        //find spacing
        var space = self.frame.width - textField2.frame.width - textField.frame.width
        var pad = space/3
        
        textField.frame.origin = CGPoint(x: currentX + pad, y: currentY)
        textField2.frame.origin = CGPoint(x: currentX + pad * 2 + textField.frame.width, y: currentY)
        currentY+=padding + textField.frame.height
        
        self.addSubview(textField)
        self.addSubview(textField2)
    }

}
