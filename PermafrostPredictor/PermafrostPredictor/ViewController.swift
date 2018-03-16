//
//  ViewController.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 2/28/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit

//Extend the UIImageView class so it can remember its image's filename
extension UIImageView {
    var imageName : String {
        set {
            self.imageName = newValue
        }
        get {
            return self.imageName
        }
    }
}

//View Controller for our 1 screen app
class ViewController: UIViewController {
    @IBOutlet weak var snowLayerImageView: UIImageView!
    @IBOutlet weak var permafrostLayerImageView: UIImageView!
    @IBOutlet weak var groundLayerImageView: UIImageView!
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Setup the image views so they know their image filenames
//        snowLayerImageView.imageName = "snow"
//        groundLayerImageView.imageName = "ground"
//        permafrostLayerImageView.imageName = "permafrost"
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
            var imageView = view.superview?.subviews[0]
            var index = 0
            var lineView = view.superview?.subviews[0]
            //find where this view is in the parent (overall view)
            for v in (view.superview?.subviews)! {
                if(v == view){
                    imageView = view.superview?.subviews[index+1]
                    lineView = view.superview?.subviews[index]
                    break
                }
                index += 1
            }
            
            //The view below it's line y position (for imageview height determination)
            var lowerBoundOfImageHeight = view.superview?.subviews[index+2].frame.minY
            
            //The image yVal
            yVal += view.bounds.height/2
            var newHeight = lowerBoundOfImageHeight! - yVal
            let heightChange = newHeight - (imageView?.frame.height)!
            
            //The previous image (will be re-sized in some way)
            var previousImageView : UIImageView = (view.superview?.subviews[index-1])! as! UIImageView
            
            //Bound the movement & Draw
            if(yVal < (previousImageView.frame.minY + imageHeightBound)){
                //The previous image is at its smallest
                previousImageView.frame = CGRect(origin: CGPoint(x: previousImageView.center.x - previousImageView.frame.width/2, y: previousImageView.frame.minY), size: CGSize(width: (previousImageView.frame.width),height: imageHeightBound))
                previousImageView.image = cropImage(image: previousImageView.image!, newWidth: previousImageView.bounds.width, newHeight: imageHeightBound)


                //Set the line & image view y values and height appropriately
                yVal = previousImageView.frame.minY + imageHeightBound
                newHeight = lowerBoundOfImageHeight! - yVal

            }
            else if(newHeight < imageHeightBound){
                //The moving view (this view's) lower bound. This is the smallest image and
                    //shouldn't move anymore

                newHeight = imageHeightBound
                yVal = (imageView?.frame.maxY)! - imageHeightBound
                
                //Resize the image view
                previousImageView.frame = CGRect(origin: CGPoint(x: previousImageView.center.x - previousImageView.frame.width/2, y: previousImageView.frame.minY), size: CGSize(width: (previousImageView.frame.width),height: (view.frame.minY) - previousImageView.bounds.minY))
                
                
                //Setup with the new cropped image
                previousImageView.image = cropImage(image: previousImageView.image! , newWidth: previousImageView.bounds.width, newHeight: (lineView?.frame.minY)! - previousImageView.bounds.minY)

            }
            else{
                //We are free to move the amount translated
                previousImageView.frame = CGRect(origin: CGPoint(x: previousImageView.center.x - previousImageView.frame.width/2, y: previousImageView.frame.minY), size: CGSize(width: (previousImageView.frame.width),height: (view.frame.minY) - previousImageView.bounds.minY))
                previousImageView.image = cropImage(image: previousImageView.image!, newWidth: previousImageView.bounds.width, newHeight: (lineView?.frame.minY)! - previousImageView.bounds.minY)

            }
            
            
            view.center = CGPoint(x:view.center.x, //only move vertically, don't change x
                y:yVal - view.bounds.height/2)
            
//            cropImage(imageView: imageView as! UIImageView, newHeight: newHeight)
            imageView!.frame = CGRect(origin: CGPoint(x: view.center.x - imageView!.frame.width/2, y: yVal), size: CGSize(width: (imageView?.frame.width)!,height: newHeight))
            
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

