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
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        //Draw Circle representing the sun
        self.path = UIBezierPath(ovalIn: CGRect(x: self.frame.width/2 - self.frame.height/2, y: 0.0, width: self.frame.size.height, height: self.frame.size.height))
        //Shape fill color
        UIColor.yellow.setFill()
        path.fill()
        
        //Stroke color
        UIColor.orange.setStroke()
        path.stroke()
        
    }
    
    override init(frame: CGRect){
        super.init(frame: frame )
        //Make the background transparent
        self.backgroundColor = .clear 
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    

}
