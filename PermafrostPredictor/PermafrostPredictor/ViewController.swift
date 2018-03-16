//
//  ViewController.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 2/28/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit

//View Controller for our 1 screen app
class ViewController: UIViewController {
    @IBOutlet weak var snowLayerImageView: UIImageView!
    @IBOutlet weak var permafrostLayerImageView: UIImageView!
    @IBOutlet weak var groundLayerImageView: UIImageView!
    
    //0, 1, 2 = snow image view
    //3, 4 = next image view
    //5, 6 == next image view
    // index/2 - 1
    var imgNames = ["Snow", "Ground", "Permafrost"]
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: To recognize a pan gesture (dragging) on a view (our lines in the UI)
    @IBAction func handleGesture(recognizer:UIPanGestureRecognizer){
        
        //get the translation movement from the recognizer
        let translation = recognizer.translation(in: self.view)
        
        //move the view
        if let view = recognizer.view{
            
            //The new yVal of the line
            var yVal = view.center.y + translation.y

            //Bounding
                //An image shouldn't be smaller than...
            let imageHeightBound: CGFloat = 40
            
            //Find where this view is inside the parent view
                //so we can resize the previous view when we change size
            var imageView :UIImageView = view.superview?.subviews[4] as! UIImageView
            var index = 0

            //find where this view is in the parent (overall view)
            for v in (view.superview?.subviews)! {
                if(v == view){
                    imageView = view.superview?.subviews[index+1] as! UIImageView
                    break
                }
                index += 1
            }
            
            //The view below it's line y position (for imageview height determination)
            let lowerBoundOfImageHeight = view.superview?.subviews[index+2].frame.minY
            
            //The image yVal
            yVal += view.bounds.height/2
            var newHeight = lowerBoundOfImageHeight! - yVal
            
            //The previous image (will be re-sized in some way)
            let previousImageView : UIImageView = (view.superview?.subviews[index-1])! as! UIImageView
            
            var previousImageNewHeight :CGFloat = (view.frame.minY) - previousImageView.frame.minY
            //Bound the movement & Draw
            if(yVal < (previousImageView.frame.minY + imageHeightBound)){
                print("yVal < ")
                //The previous image is at its smallest
                previousImageNewHeight = imageHeightBound

                //Set the line & image view y values and height appropriately
                yVal = previousImageView.frame.minY + imageHeightBound
                newHeight = lowerBoundOfImageHeight! - yVal

            }
            else if(newHeight < imageHeightBound){
                //The moving view (this view's) lower bound. This is the smallest image and
                    //shouldn't move anymore
                print("<" )
                newHeight = imageHeightBound
                yVal = (imageView.frame.maxY) - imageHeightBound
                previousImageNewHeight = yVal - view.frame.height/2 - previousImageView.frame.minY //(view.frame.minY) - previousImageView.bounds.minY

            }
            else{
                print("Free to move")
                //We are free to move the amount translated
                previousImageNewHeight = (view.frame.minY) - previousImageView.frame.minY
            }
            print(previousImageNewHeight)
            previousImageView.frame = CGRect(origin: CGPoint(x: previousImageView.frame.minX, y: previousImageView.frame.minY), size: CGSize(width: (previousImageView.frame.width),height: previousImageNewHeight))
            
            previousImageView.image = UIImage(named: imgNames[(index-1)/2 - 1])
            previousImageView.frame = CGRect(origin: CGPoint(x: previousImageView.frame.minX, y: previousImageView.frame.minY), size: CGSize(width: (previousImageView.frame.width),height: previousImageNewHeight))

            view.center = CGPoint(x:view.center.x, //only move vertically, don't change x
                y:yVal - view.frame.height/2)
            
            imageView.frame = CGRect(origin: CGPoint(x: view.center.x - imageView.frame.width/2, y: yVal), size: CGSize(width: (imageView.frame.width),height: newHeight))
            imageView.image = UIImage(named: imgNames[(index+1)/2 - 1])
            imageView.frame = CGRect(origin: CGPoint(x: view.center.x - imageView.frame.width/2, y: yVal), size: CGSize(width: (imageView.frame.width),height: newHeight))
            
        }
        //Don't have image keep moving, set translation to zero because we are done
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    //MARK: didReceiveMemoryWarning()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cropImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat)->UIImage{
        //Make the new rectangle
        let rect : CGRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: newHeight)
        //Do the crop
        var img = image
        img = UIImage(cgImage: (image.cgImage?.cropping(to: rect))!)
        return img
    }
}

