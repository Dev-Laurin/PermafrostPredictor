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
    @IBOutlet weak var atmosphericTempLabel: UILabel!
    
    
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
    var permafrostLabel: UILabel
    var permafrostImageView: UIImageView
    
    //Padding is for drawing within a view so it's not touching the edges (labels)
    var padding: CGFloat = 40.0
    //The temperature the sun is giving off
    var sunIntensity: CGFloat
    var atmosphericTemperature : CGFloat
    //The sun itself is a special view, see SunView.swift
    var sunView: SunView
    //Keep track of how deep the snow is
    var snowLevel: CGFloat
    //How deep the ground layer is
    var groundLevel: CGFloat
    //How deep the permafrost is
    var permafrostLevel: CGFloat
    //The permafrost line that is placed on screen based on user's input
    
    
    var handleSkyXPos: CGFloat
    var handleSkyYPos: CGFloat
    
    //Get the max heights of this particular screen(calculated on every device)
        //This is for drawing purposes and setting the units, device independently
    var maxSnowHeight: CGFloat
    var maxGroundHeight: CGFloat
    var groundHeightPercentage: CGFloat
    var groundTopAverageValue: CGFloat
    var groundMaxUnitHeight: CGFloat
    
    //Split snow & ground to 50% of screen
    var heightBasedOffPercentage : CGFloat //screen grows down
    
    
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
        atmosphericTemperature = 30.0
        //init the sun itself
        sunView = SunView()
        //init snow/ground levels
        snowLevel = 1.0
        groundLevel = 20.2
        permafrostLevel = max(snowLevel/10 + sunIntensity, 0)
        
        handleSkyXPos = 0.0
        handleSkyYPos = 0.0
        
        maxSnowHeight = 0.0
        maxGroundHeight = 0.0
        groundHeightPercentage = 0.5
        groundTopAverageValue = 2.0
        groundMaxUnitHeight = 10.0
        
        let screenHeight = UIScreen.main.bounds.height
        heightBasedOffPercentage = screenHeight * (0.5)
        
        permafrostImageView = UIImageView(image: UIImage(named: "PermafrostLine"))
        permafrostLabel = UILabel()
        
        //Call the super version, recommended
        super.init(coder: coder )!
    }
    
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(permafrostImageView)
        view.addSubview(permafrostLabel)
        
        //Initialize Temperature Label (Mean Temperature)
        sunLabel.text = "T = " + String(describing: sunIntensity) + " °C"
        sunLabel.sizeToFit()
        sunLabel.backgroundColor = .white
        
        //Atmospheric Temperature
        updateAtmosphericTemperatureLabel(newText: String(describing: atmosphericTemperature))
        
        //Make the Sun in its own view
        let sunViewSize: CGFloat = skyView.frame.width/3
        sunView = SunView(frame: CGRect(x:0.0, y: 0.0, width: sunViewSize, height: sunViewSize))
        //Add to the sky view
        skyView.addSubview(sunView)
        //Update the location in the sky view
        sunView.frame = CGRect(x: skyView.frame.width - sunViewSize, y: padding/2, width: sunViewSize, height: sunViewSize)
        sunView.backgroundColor = .white 
        //Setup the gesture recognizer for user interaction
      //  sunView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sunPanGestureRecognizer)))
        
        //Set the backgrounds of the views
        snowImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Snow")!)
        staticGroundLayer.backgroundColor = UIColor(patternImage: UIImage(named: "Ground")!)
        groundImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Empty")!)

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
        permafrostLabel.sizeToFit()
        
        drawPermafrost()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Draw initial here
        drawInitViews()
       
        //put labels in initial spots
        drawInitLabels()
        
        //Get the maximum our view heights can be based on this screen/device
        findMaxHeightsBasedOnScreen()
        
    }
    
    func drawInitViews(){
        //Draw views on screen

        changeViewsYValue(view: staticLineGround, newX: 0.0, newY: heightBasedOffPercentage)
        snowImageView = changeViewsYValue(view: snowImageView, newX: 0.0, newY: staticLineGround.frame.minY - snowImageView.frame.height)
        snowLineView = changeViewsYValue(view: snowLineView, newX: 0.0, newY: snowImageView.frame.minY - snowLineView.frame.height) as! UIImageView
        staticGroundLayer = changeViewsYValue(view: staticGroundLayer, newX: 0.0, newY: staticLineGround.frame.maxY)
        lineGround = changeViewsYValue(view: lineGround, newX: 0.0, newY: staticGroundLayer.frame.maxY) as! UIImageView
        groundImageView = changeViewsYValue(view: groundImageView, newX: 0.0, newY: lineGround.frame.maxY)
        
    }
    
    func drawInitLabels(){
        sunView = changeViewsYValue(view: sunView, newX: skyView.frame.width - sunView.frame.width, newY: sunView.frame.minY) as! SunView
        
        atmosphericTempLabel = changeViewsYValue(view: atmosphericTempLabel, newX: skyView.frame.minX + padding/2, newY: sunView.frame.minY) as! UILabel
        
        sunLabel = changeViewsYValue(view: sunLabel, newX: skyView.frame.minX + padding/2, newY: sunView.frame.minY + sunLabel.frame.height + padding/4) as! UILabel
        
        snowLabel = changeViewsYValue(view: snowLabel, newX: skyView.frame.maxX - snowLabel.frame.width - padding/4, newY: skyView.frame.height - snowLabel.frame.height - padding/4) as! UILabel
        
        groundLabel = changeViewsYValue(view: groundLabel, newX: staticGroundLayer.frame.maxX - groundLabel.frame.width - padding/4, newY: padding/4) as! UILabel
        
        permafrostLabel = changeViewsYValue(view: permafrostLabel, newX: groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4, newY: groundImageView.frame.maxY - permafrostLabel.frame.height - padding) as! UILabel

    }
    
    func findMaxHeightsBasedOnScreen(){
        let screenHeight = UIScreen.main.bounds.height
        
        //How much can snow grow based on sun?
        var minimumHeight = sunView.frame.minY + sunView.frame.height + snowLabel.frame.height + padding/2
        minimumHeight += padding/4
        //minimumHeight is the minimum Height we have to draw the top elements
        maxSnowHeight = heightBasedOffPercentage - minimumHeight
        
        maxGroundHeight = screenHeight - heightBasedOffPercentage //the minimum the grey view can be
    }
    

    
    //MARK: To handle when the sun is being interacted with
    //objective C selector & function doesn't create memory errors like Swift version
//    @objc func sunPanGestureRecognizer(recognizer: UIPanGestureRecognizer){
//        let translation = recognizer.translation(in: self.view)
//
//        //Get difference of movement in degrees
//        var temp = turnTranslationIntoTemp(translation: translation) + sunIntensity
//        
//        //Round and display in temp label
//        temp = roundToHundredths(num: temp)
//        sunLabel.text = String("T = " + String(describing: temp) + "°C")
//        sunLabel.sizeToFit()
//        
//        //If the user has let go, add this value to the previous one
//        if recognizer.state == UIGestureRecognizerState.ended {
//            sunIntensity = temp
//        }
//
//        //update the permafrost
//        updatePermafrostLabel()
//        
//    }
    
    func updatePermafrostLabel(){
        //update the value
        permafrostLevel = roundToHundredths(num: max(snowLevel/10 + sunIntensity, 0))
        //update the display
        permafrostLabel.text = "ALT = " + String(describing: permafrostLevel) + " m"
        permafrostLabel.sizeToFit()
        //redraw
        var permafrostRect = permafrostLabel.frame
        permafrostRect.origin = CGPoint(x: groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4, y: padding/4 + permafrostImageView.frame.maxY)
        permafrostLabel.frame = permafrostRect
    }

    //MARK: SkyView Gesture recognizer
        //Decrease the Sun Temperature based on movement
    @IBAction func handleSkyGesture(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self.view)
        
        //The starting coordinates of our
        if(recognizer.state == .began){
            handleSkyXPos = translation.x
            handleSkyYPos = translation.y
        }
        
        
        //Get the movement difference in degrees
        var temp = turnMovementIntoUnits(movement: translation.x)
        var atmosTemp = turnMovementIntoUnits(movement: translation.y)
        //The temperature is subtracting from the sun intensity
        atmosTemp = atmosTemp * -1
        temp = temp * -1
        //Add the difference to our last temp value
        temp += sunIntensity
        atmosTemp += atmosphericTemperature

       
        //Round to the Hundredths place
        temp = roundToHundredths(num: temp)
        sunLabel.text = String("T = " + String(describing: temp) + " °C")
        sunLabel.sizeToFit()
        
        atmosTemp = roundToHundredths(num: atmosTemp)
        updateAtmosphericTemperatureLabel(newText: String(describing: atmosTemp))
        
        //If the user has let go
        if recognizer.state == UIGestureRecognizerState.ended {
            sunIntensity = temp
            atmosphericTemperature = atmosTemp
        }
        drawPermafrost()
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
                let screenHeight = UIScreen.main.bounds.height
                let groundLayerHeightBound: CGFloat = padding*2 + permafrostLabel.frame.height
                
                var newImageViewHeight = screenHeight - (newLineYValue + view.frame.height)
                
                var previousViewHeight: CGFloat = (previousView?.frame.height)!

                let validMovement = getMovement(previousView: staticGroundLayer, previousHeightBound: 0.0, heightBound: groundLayerHeightBound, newLineYValue: &newLineYValue, view: view, followingMinY: screenHeight, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)

                view.frame = CGRect(origin: CGPoint(x: lineGround.frame.minX, //only move vertically, don't change x
                    y: newLineYValue), size: CGSize(width: lineGround.frame.width, height: lineGround.frame.height))
                
                groundImageView.frame = CGRect(origin: CGPoint(x: view.center.x - groundImageView.frame.width/2, y: newLineYValue + lineGround.frame.height), size: CGSize(width: (groundImageView.frame.width),height: newImageViewHeight))
                staticGroundLayer.frame = CGRect(origin: CGPoint(x: staticGroundLayer.frame.minX, y: staticGroundLayer.frame.minY), size: CGSize(width: (staticGroundLayer.frame.width),height: previousViewHeight))
                
                print("MaxGroundHeight: " + String(describing: maxGroundHeight))
                print("NewGroundHeight: " + String(describing: newImageViewHeight))
                
                //Re-draw label with new coordinates
                if(validMovement){
                    var num = 10.0 - getUnits(topAverageValue: groundTopAverageValue, maxValue: groundMaxUnitHeight, maxHeight: maxGroundHeight, newHeight: newImageViewHeight, percentage: groundHeightPercentage)
                    num = roundToHundredths(num: num)
                    groundLevel = num
                    
                    if(groundLevel == 0.0){
                        groundLabel.text = "No Organic"
                    }else{
                        groundLabel.text = "A = " + String(describing: num) + "m"
                    }
                    groundLabel.sizeToFit()
                    drawPermafrost()
                }
                
                var groundLabelNewX: CGFloat = staticGroundLayer.frame.maxX - groundLabel.frame.width - padding/4
                var groundLabelNewY: CGFloat = padding/4
                groundLabel.frame = CGRect(origin: CGPoint(x: groundLabelNewX, y: groundLabelNewY), size: CGSize(width: groundLabel.frame.width, height: groundLabel.frame.height))
                
                permafrostLabel.frame = CGRect(origin: CGPoint(x: groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4, y: newImageViewHeight - permafrostLabel.frame.height - padding), size: CGSize(width: permafrostLabel.frame.width, height: permafrostLabel.frame.height))
                
                
                drawPermafrost()
            }
            //We are moving the snow layer
            else if view == snowLineView {
                let previousView = skyView
                //How small the static ground plant layer image is allowed to be
              //  var skyViewHeightBound = heightBasedOffPercentage - maxSnowHeight
                let skyViewHeightBound: CGFloat = sunView.frame.maxY + sunLabel.frame.height + padding/2
                let heightBound: CGFloat = 0.0
                var newImageViewHeight = staticLineGround.frame.minY - (newLineYValue + view.frame.height)
                
                var previousViewHeight: CGFloat = (previousView?.frame.height)!
                
                let validMovement = getMovement(previousView: skyView, previousHeightBound: skyViewHeightBound, heightBound: heightBound, newLineYValue: &newLineYValue, view: view, followingMinY: staticLineGround.frame.minY, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)
                
                view.frame = CGRect(origin: CGPoint(x: snowLineView.frame.minX, //only move vertically, don't change x
                    y: newLineYValue), size: CGSize(width: snowLineView.frame.width, height: snowLineView.frame.height))
                
                snowImageView.frame = CGRect(origin: CGPoint(x: view.center.x - snowImageView.frame.width/2, y: newLineYValue + snowLineView.frame.height), size: CGSize(width: (snowImageView.frame.width),height: newImageViewHeight))
                skyView.frame = CGRect(origin: CGPoint(x: (skyView.frame.minX), y: (skyView.frame.minY)), size: CGSize(width: (skyView.frame.width), height: previousViewHeight))
                
                //Update label
                sunLabel.sizeToFit()
   
                //y grows down, but in the app we want it to grow up
               // var num = snowLevel + (-translation.y * 1/5.0 )
                
                snowLabel.frame = CGRect(origin: CGPoint(x: snowLabel.frame.minX, y: previousViewHeight - snowLabel.frame.height - padding/4), size: CGSize(width: snowLabel.frame.width, height: snowLabel.frame.height))
                
                
                //only update the snow level if the movement is valid
                if(validMovement){
                    
                    snowLevel = getUnits(topAverageValue: 1.0, maxValue: 5.0, maxHeight: maxSnowHeight, newHeight: newImageViewHeight, percentage: 0.66)
                    snowLevel = roundToHundredths(num: snowLevel)
                    
                    if(snowLevel == 0.0){
                        snowLabel.text = "No Snow"
                        snowLabel.sizeToFit()
                    }
                    else{
                        snowLabel.text = "S = " + String(describing: snowLevel) + " m"
                        snowLabel.sizeToFit()
                    }

                  //  updatePermafrostLabel()
                    drawPermafrost()
                }
                
                //Our gesture ended, save the ending level here. If we save it elsewhere,
                    //the number will be exponentially changed, which we don't want.
//                if recognizer.state == UIGestureRecognizerState.ended {
//                    snowLevel = num
//                }
//

                
            }
            
            //updatePermafrostLabel()
            drawPermafrost()
            
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
    
    func getUnits(topAverageValue: CGFloat, maxValue: CGFloat, maxHeight: CGFloat, newHeight: CGFloat, percentage: CGFloat)->CGFloat{
        //Find out when the switch happens (what height)
        let heightAtSwitch = maxHeight * percentage
        var value: CGFloat = 0.0
        if(newHeight < heightAtSwitch){
            //we are in the average case
            value = turnHeightMovementIntoUnits(maxHeight: heightAtSwitch, maxValue: topAverageValue, newHeight: newHeight, minValue: value)

            if(value < 0.09){
                value = 0.0
            }
        }
        else{
            //we are not in the average
            value = turnHeightMovementIntoUnits(maxHeight: maxHeight - heightAtSwitch, maxValue: maxValue, newHeight: newHeight - heightAtSwitch, minValue: topAverageValue)
            if(value > maxValue){
                value = maxValue
            }
            
        }
            return value
    }
    
    func turnHeightMovementIntoUnits(maxHeight: CGFloat, maxValue: CGFloat, newHeight: CGFloat, minValue: CGFloat)->CGFloat{
        return (newHeight * (maxValue/maxHeight)) + minValue
    }

    /**
        Updates the Atmospheric Temperature Label (the sun). Since there is a subscript, we have to use attributed strings, which is easier in a function.
     
         # Example Usage #
        ````
        //If we are in a gesture function ...
        updateAtmosphericTemperatureLabel()
        ````
    */
    func updateAtmosphericTemperatureLabel(newText: String){
        let aTemp = "A"
        let subATemp = "t"
        let restOfString = " = " + String(describing: newText) + " °C"
        let bigFont = UIFont(name: "Helvetica", size: 17)
        let smFont = UIFont(name: "Helvetica", size: 14)
        atmosphericTempLabel.attributedText = subscriptTheString(str: aTemp, toSub: subATemp, strAtEnd: restOfString, bigFont: bigFont!, smallFont: smFont!)
        atmosphericTempLabel.sizeToFit()
    }
    
    func drawPermafrost(){
//        //turn the meter metric into a y value on the screen
//        var newY =
//        var rect = permafrostImageView.frame
//        rect.origin = CGRect(x: 0.0, y: )
        
//        var newHeight = getHeightFromUnit(permafrostLevel)
        updatePermafrostLabel()
        
        var borderHeight = maxGroundHeight * groundHeightPercentage
        var heightFromUnits: CGFloat = 0.0 
        if(permafrostLevel > groundTopAverageValue){
            print("non average")
            //non average
            heightFromUnits = permafrostLevel * (maxGroundHeight/groundMaxUnitHeight)
            print("MaxGroundHeight: " + String(describing: maxGroundHeight))
            print("GroundMaxUnitHeight: " + String(describing: groundMaxUnitHeight))
            print(permafrostLevel)
            print(heightFromUnits)
        }
        else{
            print("average")
            //in the average
            heightFromUnits = permafrostLevel * ((maxGroundHeight - borderHeight)/groundMaxUnitHeight)
        }
       
        
        var startingPos = staticLineGround.frame.maxY //ground 0.0m
        var rect = permafrostImageView.frame
        print("Screen height below: ")
        print(UIScreen.main.bounds.height)
        if(startingPos + heightFromUnits > (groundImageView.frame.maxY - permafrostLabel.frame.height - padding)){
            
            rect.origin = CGPoint(x: 0.0, y: groundImageView.frame.maxY - permafrostLabel.frame.height - padding)
            permafrostImageView.frame = rect
        }
        else{
            rect.origin = CGPoint(x: 0.0, y: startingPos + heightFromUnits)
            permafrostImageView.frame = rect
        }
        
        //make the permafrost line extend to the full width of the screen
        rect = CGRect(origin: CGPoint(x: permafrostImageView.frame.minX, y: permafrostImageView.frame.minY), size: CGSize(width: UIScreen.main.bounds.width, height: permafrostImageView.frame.height))
        permafrostImageView.frame = rect
        
        print("In draw permafrost")
        print(startingPos)
        print(heightFromUnits)
        
        updatePermafrostLabel()

    }

}


