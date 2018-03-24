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
    
    @IBOutlet weak var sunImageView: UIImageView!
    @IBOutlet weak var cloudyImageView: UIImageView!
    
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
        if var view = recognizer.view{
            
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
            if var previousImageView = (view.superview?.subviews[index-1])! as? UIImageView {
                print("Previous is ImageView")
                previousViewIsImageView(index: index, yVal: &yVal, newHeight: &newHeight, previousImageView: &previousImageView, lowerBoundOfImageHeight: lowerBoundOfImageHeight!, imageHeightBound: imageHeightBound, view: &view)
            }
            //The previous view is not an image view (the sky)
            else {
                print("Previous is not imageView")
                previousViewNotImageView(index: index, yVal: &yVal, newHeight: &newHeight, imageView: &imageView, lowerBoundOfImageHeight: lowerBoundOfImageHeight!, view: view)
            }

            view.center = CGPoint(x:view.center.x, //only move vertically, don't change x
                y:yVal - view.frame.height/2)
            
//            imageView.frame = CGRect(origin: CGPoint(x: view.center.x - imageView.frame.width/2, y: yVal), size: CGSize(width: (imageView.frame.width),height: newHeight))
            print("yVal: " + String(describing: yVal))
            imageView.image = UIImage(named: imgNames[(index+1)/2 - 1])
            imageView.image = cropImage(image: imageView.image!, newWidth: imageView.frame.width, newHeight: newHeight)
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
    
    func previousViewIsImageView(index: Int, yVal: inout CGFloat, newHeight: inout CGFloat, previousImageView: inout UIImageView, lowerBoundOfImageHeight: CGFloat, imageHeightBound: CGFloat, view: inout UIView){
        
        print("Previous image y before: " + String(describing: previousImageView.frame.minY))
        
        var previousImageNewHeight :CGFloat = (view.frame.minY) - previousImageView.frame.minY

        //Bound the movement & Draw
        if(yVal < (previousImageView.frame.minY + imageHeightBound)){
            print("<")
            //The previous image is at its smallest
            previousImageNewHeight = imageHeightBound
            
            //Set the line & image view y values and height appropriately
            yVal = previousImageView.frame.minY + imageHeightBound
            newHeight = lowerBoundOfImageHeight - yVal
            
        }
        else if(newHeight < imageHeightBound){
            print("smallest this view")
            //The moving view (this view's) lower bound. This is the smallest image and
            //shouldn't move anymore
            newHeight = imageHeightBound
            yVal = (lowerBoundOfImageHeight) - imageHeightBound
            previousImageNewHeight = yVal - view.frame.height/2 - previousImageView.frame.minY //(view.frame.minY) - previousImageView.bounds.minY
            
        }
        else{
            print("Free to move")
            //We are free to move the amount translated
            previousImageNewHeight = (view.frame.minY) - previousImageView.frame.minY
        }
        print(previousImageNewHeight)
  //      previousImageView.frame = CGRect(origin: CGPoint(x: previousImageView.frame.minX, y: previousImageView.frame.minY), size: CGSize(width: (previousImageView.frame.width),height: previousImageNewHeight))
        
        previousImageView.image = UIImage(named: imgNames[(index-1)/2 - 1])
        previousImageView.image = cropImage(image: previousImageView.image!, newWidth: previousImageView.frame.width, newHeight: previousImageNewHeight)
        print("Previous ImageView y: " + String(describing: previousImageView.frame.minY))
        previousImageView.frame = CGRect(origin: CGPoint(x: previousImageView.frame.minX, y: previousImageView.frame.minY), size: CGSize(width: (previousImageView.frame.width),height: previousImageNewHeight))
    }
    
    func previousViewNotImageView(index: Int, yVal: inout CGFloat, newHeight: inout CGFloat, imageView: inout UIImageView, lowerBoundOfImageHeight: CGFloat, view: UIView){
        
        let previousView = (view.superview?.subviews[index-1])!
        var previousImageNewHeight :CGFloat = (view.frame.minY) - previousView.frame.minY
        let imageHeightBound = previousView.subviews[0].bounds.height
        
        let lowerImageHeightBound: CGFloat = 40
        //Bound the movement & Draw
        if(yVal < (previousView.frame.minY + imageHeightBound)){
            //The previous image is at its smallest
            previousImageNewHeight = imageHeightBound
            
            //Set the line & image view y values and height appropriately
            yVal = previousView.frame.minY + imageHeightBound
            newHeight = lowerBoundOfImageHeight - yVal
            
        }
        else if(newHeight < lowerImageHeightBound){
            //The moving view (this view's) lower bound. This is the smallest image and
            //shouldn't move anymore
            newHeight = lowerImageHeightBound
            yVal = (imageView.frame.maxY) - lowerImageHeightBound
            previousImageNewHeight = yVal - view.frame.height/2 - previousView.frame.minY
        }
        else{
            //We are free to move the amount translated
            previousImageNewHeight = (view.frame.minY) - previousView.frame.minY
        }
        
        previousView.frame = CGRect(origin: CGPoint(x: previousView.frame.minX, y: previousView.frame.minY), size: CGSize(width: (previousView.frame.width),height: previousImageNewHeight))
        
        //                previousImageView.image = UIImage(named: imgNames[(index-1)/2 - 1])
        //                previousImageView.frame = CGRect(origin: CGPoint(x: previousImageView.frame.minX, y: previousImageView.frame.minY), size: CGSize(width: (previousImageView.frame.width),height: previousImageNewHeight))
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

