//
//  SunView.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 3/26/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit

class SunView: UIView {

    var path: UIBezierPath!
    var color: UIColor
    
    //MARK: Initialization
    override init(frame: CGRect){
        self.color = UIColor.yellow
        super.init(frame: frame )
        //Make the background transparent
        self.backgroundColor = .clear
        
    }
    
    required init?(coder aDecoder: NSCoder){
        self.color = UIColor.yellow
        super.init(coder: aDecoder)
    }
    
    //MARK: Draw the sun
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        var strokeLineWidth: CGFloat = 3.0
        //Draw Circle representing the sun
        let frameWidth = self.frame.width - strokeLineWidth*2
        self.path = UIBezierPath(ovalIn: CGRect(x: strokeLineWidth/2, y: strokeLineWidth/2, width: self.frame.size.height - strokeLineWidth, height: self.frame.size.height - strokeLineWidth))
        //Shape fill color
        color.setFill()
        path.fill()
        
        //Stroke color
        UIColor.black.setStroke()
        path.lineWidth = strokeLineWidth
        path.stroke()
        
    }
    
    func setColor(newColor: UIColor){
        color = newColor
    }
    

    

}
