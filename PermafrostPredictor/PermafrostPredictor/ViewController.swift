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
    @IBOutlet weak var sunLabel: UILabel!
    
    //Snow Image View
    @IBOutlet weak var snowLineView: UIImageView!
    @IBOutlet weak var snowImageView: UIView!
    @IBOutlet weak var snowLabel: UILabel!
    
    //Non-Moving Ground Layer
    @IBOutlet weak var staticLineGround: UIImageView!
    @IBOutlet weak var staticGroundLayer: UIView!
    
    @IBOutlet weak var groundLabel: UILabel!
    //Moving Ground Layer
    @IBOutlet weak var lineGround: UIImageView!
    @IBOutlet weak var groundImageView: UIView!
    
    //Permafrost Layer
    @IBOutlet weak var permafrostLine: UIImageView!
    @IBOutlet weak var permafrostImageView: UIView!
    @IBOutlet weak var permafrostLabel: UILabel!
    
    var padding: CGFloat = 40.0
    var sunIntensity: CGFloat
    var sunView: SunView
    //0, 1, 2 = snow image view
    //3, 4 = next image view
    //5, 6 == next image view
    // index/2 - 1
    var imgNames = ["Snow", "Ground", "Permafrost"]
    //MARK: Initialization
    required init(coder: NSCoder){
        sunIntensity = 30.0
        sunView = SunView()
        super.init(coder: coder )!

    }
    
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialize Temperate Label
        let padding: CGFloat = 40
        sunLabel.text = "T = " + String(describing: sunIntensity) + "°C"
        sunLabel.sizeToFit()
        sunLabel.backgroundColor = .white

        //Make the Sun in its own view
        let sunViewSize: CGFloat = skyView.frame.width/3
        sunView = SunView(frame: CGRect(x:0.0, y: 0.0, width: sunViewSize, height: sunViewSize))
        //Add to the sky view
        skyView.addSubview(sunView)
        //Update the location in the sky view
        sunView.frame = CGRect(x: skyView.frame.width - sunViewSize, y: padding, width: sunViewSize, height: sunViewSize)
        sunView.backgroundColor = .white 
        //Setup the gesture recognizer for user interaction
        sunView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sunPanGestureRecognizer)))
        
        
        //Set the background of the skyView
       // skyView.backgroundColor = .cyan
        let imageView = UIImageView(image: UIImage(named: "Placeholder"))
        imageView.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: skyView.frame.width, height: skyView.frame.height))
        
     //   skyView.backgroundColor = UIColor(patternImage: UIImage(named: "Placeholder")!)
        
        //Set the backgrounds of the views
        snowImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Snow")!)
        staticGroundLayer.backgroundColor = UIColor(patternImage: UIImage(named: "Ground")!)
        groundImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Ground")!)
        permafrostImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Permafrost")!)
        
        //Have white "boxes" around the labels for better text readability
        snowLabel.backgroundColor = .white
        groundLabel.backgroundColor = .white
        permafrostLabel.backgroundColor = .white

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var rect = sunView.frame
        rect.origin = CGPoint(x: skyView.frame.width - rect.width, y: rect.minY)
        sunView.frame = rect
    }
    
    //MARK: To handle when the sun is being interacted with
    //objective C selector & function doesn't create memory errors like Swift version
    @objc func sunPanGestureRecognizer(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self.view)

        //Get difference of movement in degrees
        var temp = getDifference(translation: translation) + sunIntensity
        
        //If the user has let go, add this value to the previous one
        if recognizer.state == UIGestureRecognizerState.ended {
            sunIntensity = temp
        }
        //Round and display in temp label
        temp = NumberFormatter().number(from: roundToHundredths(num: temp, format: ".1")) as! CGFloat
        sunLabel.text = String("T = " + String(describing: temp) + "°C")
        sunLabel.sizeToFit()

    }
    
    func getDifference(translation: CGPoint)->CGFloat{
        //Find the vector magnitude of translation (hypotenuse of right triangle)
        let x = translation.x
        let y = translation.y
        var hypotenuse = x*x + y*y
        hypotenuse = hypotenuse.squareRoot()
        
        //Translate the vector magnitude (hypotenuse) of the difference in movement
        //into units of temperature
        let degreesPerUnitOfMovement:CGFloat = 1/5.0
        let degrees = degreesPerUnitOfMovement * hypotenuse
    
        return degrees
        
    }
    
    //MARK: SkyView Gesture recognizer
        //Decrease the Sun Temperature based on movement
    @IBAction func handleSkyGesture(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self.view)
        
        //Get the movement difference in degrees
        var temp = getDifference(translation: translation)
        //The temperature is subtracting from the sun intensity
        temp = temp * -1
        //Add the difference to our last temp value
        temp += sunIntensity
        //If the user has let go, add this value to the previous one
        if recognizer.state == UIGestureRecognizerState.ended {
            sunIntensity = temp
        }
        //Round to the Hundredths place
        temp = NumberFormatter().number(from: roundToHundredths(num: temp, format: ".1")) as! CGFloat
        sunLabel.text = String("T = " + String(describing: temp) + "°C")
        sunLabel.sizeToFit()
    }
    
    //MARK: To recognize a pan gesture (dragging) on a view (our lines in the UI)
    @IBAction func handleGesture(recognizer:UIPanGestureRecognizer){
        //get the translation movement from the recognizer
        let translation = recognizer.translation(in: self.view)
        
        //move the view
        if var view = recognizer.view{
            
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

                getMovement(previousView: staticGroundLayer, previousHeightBound: staticGroundHeightBound, heightBound: groundLayerHeightBound, newLineYValue: &newLineYValue, view: view, followingLineView: permafrostLine, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)

                view.frame = CGRect(origin: CGPoint(x: lineGround.frame.minX, //only move vertically, don't change x
                    y: newLineYValue), size: CGSize(width: lineGround.frame.width, height: lineGround.frame.height))
                
                groundImageView.frame = CGRect(origin: CGPoint(x: view.center.x - groundImageView.frame.width/2, y: newLineYValue + lineGround.frame.height), size: CGSize(width: (groundImageView.frame.width),height: newImageViewHeight))
                staticGroundLayer.frame = CGRect(origin: CGPoint(x: staticGroundLayer.frame.minX, y: staticGroundLayer.frame.minY), size: CGSize(width: (staticGroundLayer.frame.width),height: previousViewHeight))
                
                //Re-draw label with new coordinates
                var num = NumberFormatter().number(from: roundToHundredths(num: translation.y, format: ".1")) as! CGFloat
                groundLabel.text = "A = " + String(describing: num) + "m"
                groundLabel.sizeToFit()
                let padding: CGFloat = 20
                var groundLabelNewX: CGFloat = staticGroundLayer.frame.maxX - groundLabel.frame.width - padding/2
                var groundLabelNewY: CGFloat = previousViewHeight - padding
                groundLabel.frame = CGRect(origin: CGPoint(x: groundLabelNewX, y: groundLabelNewY), size: CGSize(width: groundLabel.frame.width, height: groundLabel.frame.height))
                
                permafrostLabel.frame = CGRect(origin: CGPoint(x: groundImageView.frame.maxX - permafrostLabel.frame.width - padding/2, y: newImageViewHeight - permafrostLabel.frame.height - padding/2), size: CGSize(width: permafrostLabel.frame.width, height: permafrostLabel.frame.height))
            }
            //We are moving the snow layer
            else if view == snowLineView {
                let previousView = skyView
                let padding: CGFloat = 20
                //How small the static ground plant layer image is allowed to be
                let skyViewHeightBound: CGFloat = sunView.frame.maxY + sunLabel.frame.height + padding*2
                let heightBound: CGFloat = 40
                var newImageViewHeight = staticLineGround.frame.minY - (newLineYValue + view.frame.height)
                
                var previousViewHeight: CGFloat = (previousView?.frame.height)!
                
                getMovement(previousView: skyView, previousHeightBound: skyViewHeightBound, heightBound: heightBound, newLineYValue: &newLineYValue, view: view, followingLineView: staticLineGround, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)
                
                view.frame = CGRect(origin: CGPoint(x: snowLineView.frame.minX, //only move vertically, don't change x
                    y: newLineYValue), size: CGSize(width: snowLineView.frame.width, height: snowLineView.frame.height))
                
                snowImageView.frame = CGRect(origin: CGPoint(x: view.center.x - snowImageView.frame.width/2, y: newLineYValue + snowLineView.frame.height), size: CGSize(width: (snowImageView.frame.width),height: newImageViewHeight))
                skyView.frame = CGRect(origin: CGPoint(x: (skyView.frame.minX), y: (skyView.frame.minY)), size: CGSize(width: (skyView.frame.width), height: previousViewHeight))
                
                //Update label
                sunLabel.sizeToFit()
                sunLabel.frame = CGRect(origin: CGPoint(x: sunLabel.frame.minX, y: previousViewHeight - padding), size: CGSize(width: sunLabel.frame.width, height: sunLabel.frame.height))
                
                
                snowLabel.frame = CGRect(origin: CGPoint(x: snowImageView.frame.maxX - snowLabel.frame.width - padding/2, y: newImageViewHeight - snowLabel.frame.height - padding/2), size: CGSize(width: snowLabel.frame.width, height: snowLabel.frame.height))
                
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
    
    func getMovement(previousView: UIView, previousHeightBound: CGFloat, heightBound: CGFloat, newLineYValue: inout CGFloat, view: UIView, followingLineView: UIImageView, previousViewNewHeight: inout CGFloat, newHeight: inout CGFloat  ){
        
        var newImageViewHeight: CGFloat = followingLineView.frame.minY - (newLineYValue + view.frame.height)
        
        var previousViewHeight: CGFloat = (previousView.frame.height)
        
        //If the new Y value of the moving ground would make the static ground image too small
        if(newLineYValue < (previousView.frame.minY + previousHeightBound)){
            //Set the Y value to go no further than the static ground image's ending Y value
            previousViewHeight = previousHeightBound
            newLineYValue = (previousView.frame.minY) + previousViewHeight
            newImageViewHeight = permafrostLine.frame.minY - newLineYValue
        }
        else if newImageViewHeight < heightBound {
            newImageViewHeight = heightBound
            newLineYValue = followingLineView.frame.minY - heightBound - view.frame.height
            previousViewHeight = newLineYValue - (previousView.frame.minY)
        }
        else {
            previousViewHeight = newLineYValue - (previousView.frame.minY)
        }
        
        newHeight = newImageViewHeight
        previousViewNewHeight = previousViewHeight
    }
    
    func cropImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat)->UIImage{
        //Make the new rectangle
        let rect : CGRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: newHeight)
        //Do the crop
        let imgCopy = image
        let img = UIImage(cgImage: (imgCopy.cgImage?.cropping(to: rect))!)
        return img
    }
    
    func roundToHundredths(num: CGFloat, format: String)->String{
        return String(format: "%\(format)f", num)
    }
}

