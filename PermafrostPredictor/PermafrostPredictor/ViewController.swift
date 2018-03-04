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
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //IDEA: TODO re-write this function to have it use a stack view owning the gesture recognizer
        //This allows the stack view to change the height of the 1st view (line) and
        //resize the 2nd view (image) accordingly
    
    //To recognize a pan gesture (dragging) on a view (our lines in the UI)
    @IBAction func handleGesture(recognizer:UIPanGestureRecognizer){
      
        //get the translation movement from the recognizer
        let translation = recognizer.translation(in: self.view)
        //move the view
        if let view = recognizer.view{
            var yVal = view.center.y + translation.y

            //Bounding
            let bottomConstraint = self.view.frame.height-40
            let topConstraint = CGFloat(60)
            
            if(yVal < topConstraint){
                yVal = topConstraint
            }
            else if( yVal > bottomConstraint){
                yVal = bottomConstraint
            }
            else{
                //Set the coordinates
                view.center = CGPoint(x:view.center.x, //only move vertically, don't change x
                                      y:yVal)
            }
            
           // var imageHeight = img.frame.height - translation.y
            let screenSize : CGRect = UIScreen.main.bounds
            let screenHeight = screenSize.height

            img.frame = CGRect(origin: CGPoint(x: view.center.x - img.frame.width/2, y: yVal), size: CGSize(width: img.frame.width,height: screenHeight - yVal))
        }
        //Don't have image keep moving, set translation to zero because we are done
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

