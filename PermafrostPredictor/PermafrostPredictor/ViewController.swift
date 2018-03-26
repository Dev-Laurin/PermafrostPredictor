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
    
    //View containing Sun
    @IBOutlet weak var skyView: UIView!
    
    //Snow Image View
    @IBOutlet weak var snowLineView: UIImageView!
    @IBOutlet weak var snowImageView: UIImageView!
    
    //Non-Moving Ground Layer
    @IBOutlet weak var staticLineGround: UIImageView!
    @IBOutlet weak var staticGroundLayer: UIImageView!
    
    //Moving Ground Layer
    @IBOutlet weak var lineGround: UIImageView!
    @IBOutlet weak var groundImageView: UIImageView!
    
    //Permafrost Layer
    @IBOutlet weak var permafrostLine: UIImageView!
    @IBOutlet weak var permafrostImageView: UIImageView!
    

    var sunLabel: UILabel = UILabel()
    var padding: CGFloat = 40.0
    //0, 1, 2 = snow image view
    //3, 4 = next image view
    //5, 6 == next image view
    // index/2 - 1
    var imgNames = ["Snow", "Ground", "Permafrost"]
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var padding: CGFloat = 40
        sunLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0) , size: CGSize(width: 30, height: 30)))
        sunLabel.text = "T = 1deg"
        sunLabel.sizeToFit()
        
        var imageView = UIImageView(image: UIImage(named: "Placeholder"))
        imageView.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: skyView.frame.width, height: skyView.frame.height))
        
        skyView.backgroundColor = UIColor(patternImage: UIImage(named: "Placeholder")!)
        var sunView = UIView()
        skyView.addSubview(sunLabel)
        skyView.addSubview(sunView)
        
        var sunViewSize: CGFloat = 100.0
        sunView.frame = CGRect(origin: CGPoint(x: skyView.frame.width - sunViewSize, y: 0.0), size: CGSize(width: sunViewSize, height: sunViewSize))
        var rect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: sunViewSize, height: sunViewSize))
        let path = UIBezierPath(ovalIn: rect)
        UIColor.yellow.setFill()
        path.fill()
        sunView.frame = rect 
        sunLabel.frame = CGRect(origin: CGPoint(x: skyView.frame.width - sunLabel.frame.width - padding, y: skyView.frame.maxY ), size: CGSize(width: sunLabel.frame.width, height: sunLabel.frame.height))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var sunViewSize: CGFloat = 100.0
        var padding: CGFloat = 40
        let sunView = SunView(frame: CGRect(x:0.0, y: 0.0, width: sunViewSize, height: sunViewSize))
        skyView.addSubview(sunView)
        sunView.frame = CGRect(x: skyView.frame.width - sunViewSize, y: padding, width: sunViewSize, height: sunViewSize)
        skyView.backgroundColor = .cyan
        
        sunView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sunPanGestureRecognizer)))
    }
    
    //MARK: To handle when the sun is being interacted with
    //objective C selector & function doesn't create memory errors like Swift version
    @objc func sunPanGestureRecognizer(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self.view)
        print("In Sun Gesture Recognizer")
        
        var x = translation.x
        var y = translation.y
        var hypotenuse = x*x + y*y
        hypotenuse = hypotenuse.squareRoot()
        print(hypotenuse)
        hypotenuse = round(hypotenuse * 100.0) / 100.0
        print(hypotenuse)
        
        sunLabel.text = String("T = " + String(describing: hypotenuse) + "°")
        var padding: CGFloat = 40
        sunLabel.sizeToFit()
        sunLabel.frame = CGRect(x: skyView.frame.width - sunLabel.frame.width - padding/2, y: skyView.frame.maxY - sunLabel.frame.height * 2, width: sunLabel.frame.width, height: sunLabel.frame.height)
        sunLabel.backgroundColor = .white
        sunLabel.layer.borderColor = UIColor.black.cgColor
    }
    
    //MARK: To recognize a pan gesture (dragging) on a view (our lines in the UI)
    @IBAction func handleGesture(recognizer:UIPanGestureRecognizer){
        
        //get the translation movement from the recognizer
        let translation = recognizer.translation(in: self.view)
        
        //move the view
        if let view = recognizer.view{
            
            //The new yVal of the line
            var newLineYValue = view.frame.minY + translation.y
            
            
            //We are moving the ground layer
            if view == lineGround {
                var previousView = staticGroundLayer
                //How small the static ground plant layer image is allowed to be
                var staticGroundHeightBound: CGFloat = 40
                var groundLayerHeightBound: CGFloat = 40
                var newImageViewHeight = permafrostLine.frame.minY - (newLineYValue + view.frame.height)
                
                var previousViewHeight: CGFloat = (previousView?.frame.height)!
                
                //If the new Y value of the moving ground would make the static ground image too small
                if(newLineYValue < (previousView!.frame.minY + staticGroundHeightBound)){
                    //Set the Y value to go no further than the static ground image's ending Y value
                    previousViewHeight = staticGroundHeightBound
                    newLineYValue = (previousView?.frame.minY)! + previousViewHeight
                    newImageViewHeight = permafrostLine.frame.minY - newLineYValue
                }
                else if newImageViewHeight < groundLayerHeightBound {
                    newImageViewHeight = groundLayerHeightBound
                    newLineYValue = permafrostLine.frame.minY - groundLayerHeightBound - lineGround.frame.height
                    previousViewHeight = newLineYValue - (previousView?.frame.minY)!
                }
                else {
                    previousViewHeight = newLineYValue - (previousView?.frame.minY)!
                }
                
                view.frame = CGRect(origin: CGPoint(x: lineGround.frame.minX, //only move vertically, don't change x
                    y: newLineYValue), size: CGSize(width: lineGround.frame.width, height: lineGround.frame.height))
                
              //  groundImageView.frame = CGRect(origin: CGPoint(x: view.center.x - groundImageView.frame.width/2, y: newLineYValue + lineGround.frame.height), size: CGSize(width: (groundImageView.frame.width),height: newImageViewHeight))
                staticGroundLayer.frame = CGRect(origin: CGPoint(x: staticGroundLayer.frame.minX, y: staticGroundLayer.frame.minY), size: CGSize(width: (staticGroundLayer.frame.width),height: previousViewHeight))
                var imageCopy = UIImage(named: imgNames[1])
                groundImageView.image = cropImage(image: imageCopy!, newWidth: groundImageView.frame.width, newHeight: newImageViewHeight)
                print(imageCopy == groundImageView.image)
                groundImageView.frame = CGRect(origin: CGPoint(x: groundImageView.frame.minX, y: newLineYValue + lineGround.frame.height), size: CGSize(width: (groundImageView.frame.width),height: newImageViewHeight))
                
                print(groundImageView.frame.height)
                print(newImageViewHeight)

            }
            //We are moving the snow layer
            else if view == snowLineView {
                
            }
            

            
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
        let imgCopy = image
        let img = UIImage(cgImage: (imgCopy.cgImage?.cropping(to: rect))!)
        return img
    }
}

