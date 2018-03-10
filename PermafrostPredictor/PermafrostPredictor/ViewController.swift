//
//  ViewController.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 2/28/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let screenSize : CGRect = UIScreen.main.bounds
    
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: To recognize a pan gesture (dragging) on a view (our lines in the UI)
    @IBAction func handleGesture(recognizer:UIPanGestureRecognizer){
        
        //Bounds for movement
            //Image should be at least
        let imageHeightBound: CGFloat = 40
      
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

            let screenSize : CGRect = UIScreen.main.bounds
            let screenHeight = screenSize.height
            
            yVal += view.bounds.height/2
            
            var imageView = view.superview?.subviews[0]
            var index = 0
            
            //find where this view is in the parent (overall view)
            for v in (view.superview?.subviews)! {
                if(v == view){
                    imageView = view.superview?.subviews[index+1]
                    break
                }
                index += 1
            }
            //Lower bound
            var lowerBound = screenHeight
            
            if(index+2 < (view.superview?.subviews.count)!){
                //lowerbound is the screenheight
                lowerBound = (view.superview?.subviews[index+2].frame.minY)!
            }
            
            let heightChange = lowerBound - yVal
            
            
            //Calculate equal movement of previous subviews (resizing)
                //Get Height of each image
            
            //for each previous view, resize it to fit the new size
            //view = current line clicked on
            //view.superview = stackview
            //view.superview.subviews[index] = our line view
            //index + 1 = imgView corresponding to line view
            //index + 2 = next line view up
            //index + 3 its img
            //index + 4 next line ...
            //0 1, 2 3, 3 4, 5 6, ...
            var superviewSubviews = view.superview?.subviews
            
            var heightLeftOver: CGFloat = 0
            let amountOfViewsAbove = ((superviewSubviews?.count)! - index)/2
            for var i in index+2..<(view.superview!.subviews.count){
                //resizeView(view: view, )
                //superviewSubviews[index]
                
                //Move the amount moved with respect to bounds and other views
                let inParentImageView = superviewSubviews![i+1]
                let inParentLineView = superviewSubviews![i]
                var aboveImageHeightChange = inParentImageView.frame.height - heightChange/CGFloat(amountOfViewsAbove)
                
                if(aboveImageHeightChange > imageHeightBound){
                    //the height change can occur
                    inParentImageView.frame = CGRect(origin: CGPoint(x: inParentLineView.center.x - inParentImageView.frame.width/2, y: inParentImageView.frame.minY), size: CGSize(width: (inParentImageView.frame.width),height: aboveImageHeightChange))
                }
                else{
                    //the height change cannot occur
                    heightLeftOver = -(aboveImageHeightChange)

                    //The most we can move
                    aboveImageHeightChange = aboveImageHeightChange - imageHeightBound
                    heightLeftOver -= aboveImageHeightChange
                    
                    //Move a smaller amount if possible
                    inParentImageView.frame = CGRect(origin: CGPoint(x: inParentLineView.center.x - inParentImageView.frame.width/2, y: inParentImageView.frame.minY), size: CGSize(width: (inParentImageView.frame.width),height: aboveImageHeightChange))
                    
                }
                i+=1 //skip the imageviews
                
            }
            
            imageView!.frame = CGRect(origin: CGPoint(x: view.center.x - imageView!.frame.width/2, y: yVal), size: CGSize(width: (imageView?.frame.width)!,height: heightChange)) // screenHeight - yVal
        }
        //Don't have image keep moving, set translation to zero because we are done
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    //MARK: didReceiveMemoryWarning()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

