//
//  ViewController.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 2/28/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var line: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //To recognize a pan gesture (dragging) on a view (our lines in the UI)
    @IBAction func handleLineGesture(recognizer:UIPanGestureRecognizer){
        //get the translation movement from the recognizer
        let translation = recognizer.translation(in: self.view)
        //move the view
        if let view = recognizer.view{
            var yVal = view.center.y + translation.y
            
            //Bounding
            let bottomConstraint = self.view.frame.height-40
            if((view.center.y + translation.y) < 40){
                yVal = 40
            }
            else if( (view.center.y + translation.y) > bottomConstraint){
                yVal = bottomConstraint
            }
            
            //Set the coordinates
            view.center = CGPoint(x:view.center.x, //only move vertically, don't change x 
                                  y:yVal)
        }
        //Don't have image keep moving, set translation to zero because we are done 
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

