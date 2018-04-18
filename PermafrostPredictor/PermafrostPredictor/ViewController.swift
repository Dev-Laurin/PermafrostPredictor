//
//  ViewController.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 2/28/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit

/**
    Our one-page app. This is where everything happens, the view controller.
*/
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
    @IBOutlet weak var permafrostLabel: UILabel!
    
    //Padding is for drawing within a view so it's not touching the edges (labels)
    var padding: CGFloat = 40.0
    //The temperature the sun is giving off
    var sunIntensity: CGFloat
    //The sun itself is a special view, see SunView.swift
    var sunView: SunView
    //Keep track of how deep the snow is
    var snowLevel: CGFloat
    //How deep the ground layer is
    var groundLevel: CGFloat
    //How deep the permafrost is
    var permafrostLevel: CGFloat

    //MARK: Initialization
    /**
         Initializer for the View Controller. Use to initialize the label values, can be used to assign them from storage or set to default values.
     
         # Example: #
         ````
         //Set how deep the snow level is when the app first starts
         snowLevel = 2.0 //meters
         ````
    */
    required init(coder: NSCoder){
        //initialize starting sun temperature
        sunIntensity = 30.0
        //init the sun itself
        sunView = SunView()
        //init snow/ground levels
        snowLevel = 30.0
        groundLevel = 20.2
        permafrostLevel = max(snowLevel/10 + sunIntensity, 0)
        //Call the super version, recommended
        super.init(coder: coder )!
    }
    
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialize Temperature Label
        sunLabel.text = "T = " + String(describing: sunIntensity) + " °C"
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
        
        //Set the backgrounds of the views
        snowImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Snow")!)
        staticGroundLayer.backgroundColor = UIColor(patternImage: UIImage(named: "Ground")!)
        groundImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Empty")!)
      //  permafrostImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Permafrost")!)
        
        //Initialize Labels
            //Have white "boxes" around the labels for better text readability
        snowLabel.backgroundColor = .white
        snowLabel.text = "S = " + String(describing: snowLevel) + " m"
        snowLabel.sizeToFit()
        
        groundLabel.text = "A = " + String(describing: groundLevel) + " m"
        groundLabel.backgroundColor = .white
        groundLabel.sizeToFit()
        
        permafrostLabel.text = "ALT = " + String(describing: permafrostLevel) + " m"
        permafrostLabel.backgroundColor = .white

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Draw initial here
        var rect = sunView.frame
        rect.origin = CGPoint(x: skyView.frame.width - rect.width, y: rect.minY)
        sunView.frame = rect
        
        //put labels in initial spots
        var tempRect = sunLabel.frame
        tempRect.origin = CGPoint(x: skyView.frame.width - sunLabel.frame.width - padding/2, y: skyView.frame.height - sunLabel.frame.height - padding/4)
        sunLabel.frame = tempRect
        
        var snowRect = snowLabel.frame
        snowRect.origin = CGPoint(x: snowImageView.frame.maxX - snowLabel.frame.width - padding/4, y: snowImageView.frame.height - snowLabel.frame.height - padding/4)
        snowLabel.frame = snowRect
        
        var groundRect = groundLabel.frame
        groundRect.origin = CGPoint(x: staticGroundLayer.frame.maxX - groundLabel.frame.width - padding/4, y: staticGroundLayer.frame.height - groundLabel.frame.height - padding/4)
        groundLabel.frame = groundRect
        
        var permafrostRect = permafrostLabel.frame
        permafrostRect.origin = CGPoint(x: groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4, y: groundImageView.frame.height - permafrostLabel.frame.height - padding/4)
        permafrostLabel.frame = permafrostRect
    }
    
    //MARK: To handle when the sun is being interacted with
    //objective C selector & function doesn't create memory errors like Swift version
    @objc func sunPanGestureRecognizer(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self.view)

        //Get difference of movement in degrees
        var temp = turnTranslationIntoTemp(translation: translation) + sunIntensity
        
        //If the user has let go, add this value to the previous one
        if recognizer.state == UIGestureRecognizerState.ended {
            sunIntensity = temp
        }
        //Round and display in temp label
        temp = roundToHundredths(num: temp)
        sunLabel.text = String("T = " + String(describing: temp) + "°C")
        sunLabel.sizeToFit()
        
        //update the permafrost
        updatePermafrostLabel()
        
    }
    
    func updatePermafrostLabel(){
        //update the value
        permafrostLevel = max(snowLevel/10 + sunIntensity, 0)
        //update the display
        permafrostLabel.text = "ALT = " + String(describing: permafrostLevel) + " m"
    }

    //MARK: SkyView Gesture recognizer
        //Decrease the Sun Temperature based on movement
    @IBAction func handleSkyGesture(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self.view)
        
        //Get the movement difference in degrees
        var temp = turnTranslationIntoTemp(translation: translation)
        //The temperature is subtracting from the sun intensity
        temp = temp * -1
        //Add the difference to our last temp value
        temp += sunIntensity
        //If the user has let go, add this value to the previous one
        if recognizer.state == UIGestureRecognizerState.ended {
            sunIntensity = temp
        }
        //Round to the Hundredths place
        temp = roundToHundredths(num: temp)
        sunLabel.text = String("T = " + String(describing: temp) + " °C")
        sunLabel.sizeToFit()
        
        updatePermafrostLabel()
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
                let previousView = staticGroundLayer
                //How small the static ground plant layer image is allowed to be
                let staticGroundHeightBound: CGFloat = 40
                let screenHeight = UIScreen.main.bounds.height
                let groundLayerHeightBound: CGFloat = padding*2 + permafrostLabel.frame.height
                
                var newImageViewHeight = screenHeight - (newLineYValue + view.frame.height)
                
                var previousViewHeight: CGFloat = (previousView?.frame.height)!

                getMovement(previousView: staticGroundLayer, previousHeightBound: staticGroundHeightBound, heightBound: groundLayerHeightBound, newLineYValue: &newLineYValue, view: view, followingMinY: screenHeight, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)

                view.frame = CGRect(origin: CGPoint(x: lineGround.frame.minX, //only move vertically, don't change x
                    y: newLineYValue), size: CGSize(width: lineGround.frame.width, height: lineGround.frame.height))
                
                groundImageView.frame = CGRect(origin: CGPoint(x: view.center.x - groundImageView.frame.width/2, y: newLineYValue + lineGround.frame.height), size: CGSize(width: (groundImageView.frame.width),height: newImageViewHeight))
                staticGroundLayer.frame = CGRect(origin: CGPoint(x: staticGroundLayer.frame.minX, y: staticGroundLayer.frame.minY), size: CGSize(width: (staticGroundLayer.frame.width),height: previousViewHeight))
                
                //Re-draw label with new coordinates
                var num = roundToHundredths(num: translation.y)
                groundLabel.text = "A = " + String(describing: num) + "m"
                groundLabel.sizeToFit()
                var groundLabelNewX: CGFloat = staticGroundLayer.frame.maxX - groundLabel.frame.width - padding/4
                var groundLabelNewY: CGFloat = previousViewHeight - groundLabel.frame.height - padding/4
                groundLabel.frame = CGRect(origin: CGPoint(x: groundLabelNewX, y: groundLabelNewY), size: CGSize(width: groundLabel.frame.width, height: groundLabel.frame.height))
                
                permafrostLabel.frame = CGRect(origin: CGPoint(x: groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4, y: newImageViewHeight - permafrostLabel.frame.height - padding), size: CGSize(width: permafrostLabel.frame.width, height: permafrostLabel.frame.height))
            }
            //We are moving the snow layer
            else if view == snowLineView {
                let previousView = skyView
                //How small the static ground plant layer image is allowed to be
                let skyViewHeightBound: CGFloat = sunView.frame.maxY + sunLabel.frame.height + padding
                let heightBound: CGFloat = 40
                var newImageViewHeight = staticLineGround.frame.minY - (newLineYValue + view.frame.height)
                
                var previousViewHeight: CGFloat = (previousView?.frame.height)!
                
                getMovement(previousView: skyView, previousHeightBound: skyViewHeightBound, heightBound: heightBound, newLineYValue: &newLineYValue, view: view, followingMinY: staticLineGround.frame.minY, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)
                
                view.frame = CGRect(origin: CGPoint(x: snowLineView.frame.minX, //only move vertically, don't change x
                    y: newLineYValue), size: CGSize(width: snowLineView.frame.width, height: snowLineView.frame.height))
                
                snowImageView.frame = CGRect(origin: CGPoint(x: view.center.x - snowImageView.frame.width/2, y: newLineYValue + snowLineView.frame.height), size: CGSize(width: (snowImageView.frame.width),height: newImageViewHeight))
                skyView.frame = CGRect(origin: CGPoint(x: (skyView.frame.minX), y: (skyView.frame.minY)), size: CGSize(width: (skyView.frame.width), height: previousViewHeight))
                
                //Update label
                sunLabel.sizeToFit()
                sunLabel.frame = CGRect(origin: CGPoint(x: sunLabel.frame.minX, y: previousViewHeight - padding/2), size: CGSize(width: sunLabel.frame.width, height: sunLabel.frame.height))
                
                //y grows down, but in the app we want it to grow up
                var num = snowLevel + (-translation.y * 1/5.0 )
                num = roundToHundredths(num: num)
                snowLabel.frame = CGRect(origin: CGPoint(x: snowImageView.frame.maxX - snowLabel.frame.width - padding/4, y: snowImageView.frame.height - snowLabel.frame.height - padding/4), size: CGSize(width: snowLabel.frame.width, height: snowLabel.frame.height))
                
                snowLevel = num
                //Our gesture ended, save the ending level here. If we save it elsewhere,
                    //the number will be exponentially changed, which we don't want.
                if recognizer.state == UIGestureRecognizerState.ended {
                    snowLevel = num
                }
                snowLabel.text = "S = " + String(describing: snowLevel) + " m"
                snowLabel.sizeToFit()

                
            }
            
            updatePermafrostLabel()
            
        }
        //Don't have image keep moving, set translation to zero because we are done
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    //MARK: didReceiveMemoryWarning()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Helper Functions
    
    func getMovement(previousView: UIView, previousHeightBound: CGFloat, heightBound: CGFloat, newLineYValue: inout CGFloat, view: UIView, followingMinY: CGFloat, previousViewNewHeight: inout CGFloat, newHeight: inout CGFloat  ){
        
        var newImageViewHeight: CGFloat = followingMinY - (newLineYValue + view.frame.height)
        
        var previousViewHeight: CGFloat = (previousView.frame.height)
        
        //If the new Y value of the moving ground would make the static ground image too small
        if(newLineYValue < (previousView.frame.minY + previousHeightBound)){
            //Set the Y value to go no further than the static ground image's ending Y value
            previousViewHeight = previousHeightBound
            newLineYValue = (previousView.frame.minY) + previousViewHeight
            newImageViewHeight = followingMinY - newLineYValue - view.frame.height
        }
        else if newImageViewHeight < heightBound {
            newImageViewHeight = heightBound
            newLineYValue = followingMinY - heightBound - view.frame.height
            previousViewHeight = newLineYValue - (previousView.frame.minY)
        }
        else {
            previousViewHeight = newLineYValue - (previousView.frame.minY)
        }
        
        newHeight = newImageViewHeight
        previousViewNewHeight = previousViewHeight
        
    }
    
    /**
        To handle the difference in x and y translation from the sun while panning to change temperature. This takes the translation point, finds the hypotenuse of the right triangle, and turns its value into a temperature degrees value.
     
        - parameter translation: The movement of the user's finger as given by a gesture recognizer.
     
         # Usage Example: #
         ````
         @IBAction func handleSkyGesture(recognizer: UIPanGestureRecognizer){
             let translation = recognizer.translation(in: self.view)
     
             //Get the movement difference in degrees
             var temp = turnTranslationIntoTemp(translation: translation)
         }
         ````
    */
    func turnTranslationIntoTemp(translation: CGPoint)->CGFloat{
        //Find the vector magnitude of translation (hypotenuse of right triangle)
        let x = translation.x
        let y = translation.y
        var hypotenuse = x*x + y*y
        hypotenuse = hypotenuse.squareRoot()
        
        //Translate the vector magnitude (hypotenuse) of the difference in movement
        //into units of temperature
        return turnMovementIntoUnits(movement: hypotenuse)
    }
    
    /**
        Turns the movement tracked by the device (how much the finger moved on the screen) into units we want for our UI. We don't want huge changes from really small gestures.
     
        - parameter movement: The translation, in gesture recognizer units. (Is a number, not a recognizer translation. So no .x or .y).
     
         # Usage Example: #
         ````
         var translated = translation.x
         var degrees = turnMovementIntoUnits(movement: translated)
         ````
    */
    func turnMovementIntoUnits(movement: CGFloat)->CGFloat{
        //For every 5 units of movement translation, have our unit go up 1
        //Example: My finger swiped 25 movement in x direction, but I only want the temperature to change by 5
        let unitPerMovement:CGFloat = 1/5.0
        let units = unitPerMovement * movement
        return units
    }
    
    /**
        This function, given an image, makes a copy of the image, crops it, and returns the new cropped image of the new width and height.
     
        - parameter image: A valid, croppable, UIImage.
        - parameter newWidth: The desired new width of the cropped image.
        - parameter newHeight: The desired new height of the cropped image.
     
        # Usage Example: #
        ````
        let image = UIImage(named: "testImage")
        var croppedWidth = 500
        var croppedHeight = 400
        var croppedImage = cropImage(image: image, newWidth: croppedWidth, newHeight: croppedHeight)
        ````
    */
    func cropImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat)->UIImage{
        //Make the new rectangle
        let rect : CGRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: newHeight)
        //Do the crop
        let img = UIImage(cgImage: (image.cgImage?.cropping(to: rect))!)
        return img
    }
    
    /**
        Given a CGFloat, return a string of the number rounded to the hundredths place.
     
        - parameter num: A CGFloat to be rounded.
     
         # Usage Example: #
         ````
         var temp = 4.5654654
         temp = roundToHundredths(num: temp)
         //temp now is 4.56
         ````
    */
    func roundToHundredths(num: CGFloat)->CGFloat{
        //Round to the Hundredths place, this is the format string
        let format = ".1"
        return NumberFormatter().number(from:(String(format: "%\(format)f", num))) as! CGFloat
    }
}

