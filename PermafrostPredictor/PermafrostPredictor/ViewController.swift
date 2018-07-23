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
    
    //Ground Temperature Label
    var groundTempLabel: UILabel
    
    //Padding is for drawing within a view so it's not touching the edges (labels)
    var padding: CGFloat = 40.0
    //The temperature the sun is giving off
    var sunIntensity: CGFloat
    var atmosphericTemperature : CGFloat
    //The sun itself
    @IBOutlet weak var sunView: UIImageView!
    //How deep the ground layer is
    var groundLevel: CGFloat
    //How deep the permafrost is
    var permafrostLevel: CGFloat
    //The permafrost line that is placed on screen based on user's input
    
    @IBOutlet weak var stackView: UIStackView!
    
    var handleSkyXPos: CGFloat
    var handleSkyYPos: CGFloat
    
    //Get the max heights of this particular screen(calculated on every device)
        //This is for drawing purposes and setting the units, device independently
    var maxSnowHeight: CGFloat
    var maxGroundHeight: CGFloat
    var maxOrganicLayerHeight: CGFloat
    var groundHeightPercentage: CGFloat
    var groundTopAverageValue: CGFloat
    var groundMaxUnitHeight: CGFloat
    var skyHeight: CGFloat
    var skyWidth: CGFloat
    var screenHeight: CGFloat
    var screenWidth: CGFloat
    
    //Split snow & ground to 50% of screen
    var heightBasedOffPercentage : CGFloat //screen grows down
    
    //Inputs for permafrost levels
    var Kvf: Double
    var Kvt: Double
    var Kmf: Double
    var Kmt: Double
    var Cmf: Double
    var Cmt: Double
    var Cvf: Double
    var Cvt: Double
    var Hs: Double
    var Hv: Double
    var Cs: Double //volumetric heat capacity of snow
    var Tgs: Double

    //MARK: Initialization
    /**
         Initializer for the View Controller. Use to initialize the label values, can be used to assign them from storage or set to default values.
     
         # Example: #
         ````
         //Set how deep the snow level is when the app first starts
         Hs = 2.0 //meters
         ````
    */
    required init(coder: NSCoder){
        //screen size
        screenHeight = UIScreen.main.bounds.height
        screenWidth = UIScreen.main.bounds.width
        
        //initialize starting sun temperature
        sunIntensity = 10.0
        atmosphericTemperature = 25.0

        //init snow/ground levels
        groundLevel = 20.2
        permafrostLevel = 0 //max(Hs/10 + sunIntensity, 0)
        
        
        handleSkyXPos = 0.0
        handleSkyYPos = 0.0
        
        maxSnowHeight = 0.0
        maxGroundHeight = 0.0
        groundHeightPercentage = 0.0
        groundTopAverageValue = 0.0
        groundMaxUnitHeight = 0.25
        maxOrganicLayerHeight = (screenHeight * 0.15)
        
        heightBasedOffPercentage = UIScreen.main.bounds.height * (0.5)
        
        permafrostImageView = UIImageView(image: UIImage(named: "PermafrostLine"))
        permafrostLabel = UILabel()
        
        groundTempLabel = UILabel()
        
        skyHeight = 0.0
        skyWidth = 0.0
        
        
        Kvf = 0.25    //Thermal conductivity of frozen organic layer 
        Kvt = 0.1     //Thermal conductivity of thawed organic layer
        Kmf = 1.8     //Thermal conductivity of frozen mineral soil
        Kmt = 1.0     //Thermal conductivity of thawed mineral soil
        Cmf = 2000000 //Volumetric heat capacity of frozen soil
        Cmt = 3000000 //Volumetric heat capacity of thawed soil
        Cvf = 1000000 //Volumetric heat capacity of frozen moss
        Cvt = 2000000 //Volumetric heat capacity of thawed moss
        Hs = 0.3  //Snow height
        Hv = 0.25 //Thickness of vegetation
        Cs = 500000.0  //Volumetric heat capacity of snow
        Tgs = 0 //Mean annual temperature at the top of mineral layer
        
        
        //Call the super version, recommended
        super.init(coder: coder )!
    }
    
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(permafrostImageView)
        view.addSubview(permafrostLabel)
        
        view.addSubview(groundTempLabel)
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Sky")!)
        
        //Initialize Temperature Label (Mean Temperature)
        sunLabel.text = "Mean Air Temp = " + String(describing: sunIntensity) + " °C"
        sunLabel.sizeToFit()
        sunLabel.backgroundColor = .white
        
        //Atmospheric Temperature
        updateAtmosphericTemperatureLabel(newText: String(describing: atmosphericTemperature))
        atmosphericTempLabel.backgroundColor = .white 

        //Set the backgrounds of the views
        snowImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Snow")!)
        staticGroundLayer.backgroundColor = UIColor(patternImage: UIImage(named: "Ground")!)
        groundImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Empty")!)

        //Initialize Labels
            //Have white "boxes" around the labels for better text readability
        snowLabel.backgroundColor = .white
        snowLabel.text = "Snow Height = " + String(describing: Hs) + " m"
        snowLabel.sizeToFit()
        
        groundLabel.text = "Organic Layer Thickness = " + String(describing: groundLevel) + " m"
        groundLabel.backgroundColor = .white
        groundLabel.sizeToFit()
        
        permafrostLabel.text = "Active Layer Thickness = " + String(describing: permafrostLevel) + " m"
        permafrostLabel.backgroundColor = .white
        permafrostLabel.sizeToFit()
        
        groundTempLabel.text = "Mean Annual Ground Temp = " + String(describing: Tgs) + " °C"
        groundTempLabel.backgroundColor = .white
        groundTempLabel.sizeToFit()
        
        drawPermafrost()
        
        skyHeight = skyView.frame.height
        skyWidth = skyView.frame.width
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       draw()
        
    }
    
    func draw(){

        //Draw initial here
        drawInitViews()
        
        //put labels in initial spots
        drawInitLabels()
        
        //Get the maximum our view heights can be based on this screen/device
        findMaxHeightsBasedOnScreen()
        
    }
    
    
    func drawInitViews(){

        //Draw views on screen
        //Make the Sun in its own view
        skyView.frame = CGRect(origin: CGPoint(x: 0.0, y:0.0), size: CGSize(width: skyWidth, height: skyHeight))
        //make transparent
        skyView.backgroundColor = UIColor(white: 1, alpha: 0)
        let sunViewSize: CGFloat = skyView.frame.width/3
        
        sunView.frame = CGRect(origin: CGPoint(x:skyView.frame.width - sunViewSize, y: padding/2), size: CGSize(width: sunViewSize, height: sunViewSize))

        staticLineGround = changeViewsYValue(view: staticLineGround, newX: 0.0, newY: heightBasedOffPercentage) as! UIImageView

        snowImageView = changeViewsYValue(view: snowImageView, newX: 0.0, newY: staticLineGround.frame.minY - snowImageView.frame.height)
        snowImageView.frame.size = CGSize(width: snowImageView.frame.width, height: maxSnowHeight)
        snowLineView = changeViewsYValue(view: snowLineView, newX: 0.0, newY: snowImageView.frame.minY - snowLineView.frame.height) as! UIImageView
        staticGroundLayer = changeViewsYValue(view: staticGroundLayer, newX: 0.0, newY: staticLineGround.frame.maxY)
        lineGround = changeViewsYValue(view: lineGround, newX: 0.0, newY: staticGroundLayer.frame.maxY) as! UIImageView
        groundImageView = changeViewsYValue(view: groundImageView, newX: 0.0, newY: lineGround.frame.maxY)
        
        staticLineGround = changeViewsYValue(view: staticLineGround, newX: 0.0, newY: heightBasedOffPercentage) as! UIImageView
        
    }
    
    func drawInitLabels(){
   
        atmosphericTempLabel = changeViewsYValue(view: atmosphericTempLabel, newX: skyView.frame.minX + padding/2, newY: sunView.frame.minY) as! UILabel
        
        sunLabel = changeViewsYValue(view: sunLabel, newX: skyView.frame.minX + padding/2, newY: sunView.frame.minY + sunLabel.frame.height + padding/4) as! UILabel
        
        snowLabel = changeViewsYValue(view: snowLabel, newX: skyView.frame.maxX - snowLabel.frame.width - padding/4, newY: skyView.frame.height - snowLabel.frame.height - padding/4) as! UILabel
        
        groundLabel = changeViewsYValue(view: groundLabel, newX: staticGroundLayer.frame.maxX - groundLabel.frame.width - padding/4, newY: padding/4) as! UILabel
        
        permafrostLabel = changeViewsYValue(view: permafrostLabel, newX:  groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4 , newY: self.view.frame.maxY - permafrostLabel.frame.height - padding/4 ) as! UILabel
        
        groundTempLabel.frame.origin = CGPoint(x:  groundImageView.frame.maxX - groundTempLabel.frame.width - padding/4, y: permafrostLabel.frame.minY  - groundTempLabel.frame.height - padding/4 )

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
    
    func updatePermafrostLabel(){
        //update the value
        permafrostLevel = CGFloat(computePermafrost(Kvf: Kvf, Kvt: Kvt, Kmf: Kmf, Kmt: Kmt, Cmf: Cmf, Cmt: Cmt, Cvf: Cvf, Cvt: Cvt, Hs: Hs, Hv: Hv, Cs: Cs, Tgs: &Tgs, tTemp: Double(sunIntensity), aTemp: Double(atmosphericTemperature)))
        //update the display
        permafrostLevel = roundToHundredths(num: permafrostLevel)
        permafrostLabel.text = "Active Layer Thickness = " + String(describing: permafrostLevel) + " m"
        permafrostLabel.sizeToFit()
        
        //update ground temperature label
        Tgs = Double(roundToHundredths(num: CGFloat(Tgs)))
        groundTempLabel.text = "Mean Annual Ground Temp = " + String(describing: Tgs)
        groundTempLabel.sizeToFit()
 }
    
    //Snow layer was tapped - display values for entering
    @IBAction func snowLayerTapGesture(_ sender: UITapGestureRecognizer){
        //make popup
        let textBoxPopup = PopUpView()
        
        textBoxPopup.addTitle(title: "Volumetric Heat Capacity of Snow")
        
        textBoxPopup.addTextField(text: String(Cs), tag: 0)
        
        textBoxPopup.addButton(buttonText: "Submit", callback: snowPopupSubmitted)
        
        //create a greyed out view to go underneath so user knows this popup is active
        addGreyedOutView()
        
        //resize view to fit elements
        textBoxPopup.resizeView()
        
        self.view.addSubview(textBoxPopup)
    }
    
    func snowPopupSubmitted(dictionary: [Int: String]){
        var dict = dictionary
        
        //check that the input is valid
        checkIfValidNumber(tag: 0, variable: &Cs, errorMessage: "Invalid Cs", dict: &dict)
        
        drawPermafrost()
    }
    
    func addGreyedOutView(){
        //create a greyed out view to go underneath so user knows this popup is active
        let greyView = UIView()
        greyView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        greyView.frame = self.view.frame
        greyView.tag = 100
        
        self.view.addSubview(greyView)
    }
    
    @IBAction func staticGroundLayerTapGesture(_ sender: UITapGestureRecognizer) {
        
        //Make a new popup - give position on screen x & y
        let textBoxPopup = PopUpView()
        //set background color
        textBoxPopup.setBackGroundColor(color: UIColor(white: 1, alpha: 1))
        //add title to top
        textBoxPopup.addTitle(title: "Thermal Conductivity")
        //Kvt - thermal conductivity "thawed" & Kvf - "frozen"
        textBoxPopup.addLabels(text: "thawed", text2: "frozen") //give a storage place for value upon submit
        //Make the editable fields for user input
        textBoxPopup.addTextFields(text: String(Kvt), text2: String(Kvf), outputTag1: 0, outputTag2: 1)
        
        //Volumetric Heat capacity
        textBoxPopup.addTitle(title: "Volumetric Heat Capacity")
        //Cvt - "thawed" volumetric heat capacity & Cvf
        textBoxPopup.addLabels(text: "thawed", text2: "frozen")
        //make the fields
        textBoxPopup.addTextFields(text: String(Cvt), text2: String(Cvf), outputTag1: 2, outputTag2: 3)

        //Add submit button
        textBoxPopup.addButton(buttonText: "Submit", callback: popUpButtonPressed)
        
        //resize popup to fit the elements better - cleaner look
        textBoxPopup.resizeView()
        
        //create a greyed out view to go underneath so user knows this popup is active
        addGreyedOutView()
        self.view.addSubview(textBoxPopup)
    }
    
    func saveTextFields(subviews: [UIView], values: [Int])->[Int: String]{
        
        var dict: [Int: String] = [:]
        for view in subviews {
            for v in values {
                if view.tag == v {
                    let textField:UITextField = view as! UITextField
                    dict[v] = textField.text
                }
            }
        }
        return dict
    }
    
    func popUpButtonPressed(dictionary: [Int: String]){
        
       var dict = dictionary
        //save the values - but test if they can be converted to numbers first
        checkIfValidNumber(tag: 0, variable: &Kvt, errorMessage: "Invalid Kvt", dict: &dict)
        checkIfValidNumber(tag: 1, variable: &Kvf, errorMessage: "Invalid Kvf", dict: &dict)
        checkIfValidNumber(tag: 2, variable: &Cvt, errorMessage: "Invalid Cvt", dict: &dict)
        checkIfValidNumber(tag: 3, variable: &Cvf, errorMessage: "Invalid Cvf", dict: &dict)

        drawPermafrost()
    }
    
    @IBAction func mineralLayerTapGesture(_ sender: UITapGestureRecognizer){
        let textBoxPopup = PopUpView()
        
        textBoxPopup.addTitle(title: "Porosity")
        textBoxPopup.addTextField(text: "porosity?", tag: 0)
        
        textBoxPopup.addTitle(title: "Thermal Conductivity")
        textBoxPopup.addLabels(text: "thawed", text2: "frozen")
        textBoxPopup.addTextFields(text: String(Kmt), text2: String(Kmf), outputTag1: 1, outputTag2: 2)
        textBoxPopup.addTitle(title: "Volumetric Heat Capacity")
        textBoxPopup.addLabels(text: "thawed", text2: "frozen")
        textBoxPopup.addTextFields(text: String(Cmt), text2: String(Cmf), outputTag1: 3, outputTag2: 4)
        textBoxPopup.addButton(buttonText: "Submit", callback: mineralPopupButtonPressend)
        
        textBoxPopup.resizeView()
        
        addGreyedOutView()
        self.view.addSubview(textBoxPopup)
    }
    
    func mineralPopupButtonPressend(dictionary: [Int: String]){
        var dict = dictionary
        
        checkIfValidNumber(tag: 1, variable: &Kmt, errorMessage: "Invalid Kmt", dict: &dict)
        checkIfValidNumber(tag: 2, variable: &Kmf, errorMessage: "Invalid Kmf", dict: &dict)
        checkIfValidNumber(tag: 3, variable: &Cmt, errorMessage: "Invalid Cmt", dict: &dict)
        checkIfValidNumber(tag: 4, variable: &Cmf, errorMessage: "Invalid Cmf", dict: &dict)
        
        drawPermafrost()
    }
    
    
    func checkIfValidNumber(tag: Int, variable: inout Double, errorMessage: String, dict: inout [Int: String]){
        if let x = Double(dict[tag]!) {
            variable = x
        }
        else {
            let alert = UIAlertController(title: "Input Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    //Given an array of floats, find spacing that allows the items to be close to centered
    func drawEvenly(items: [CGFloat], totalAvailableWidth: CGFloat)->CGFloat{
        var totalSpacing = totalAvailableWidth
        //Subtract all the items' widths that are on one line
        for i in items{
            totalSpacing -= i
        }
        return totalSpacing/CGFloat(items.count + 1) //the most even spacing distributed among the items (space in bet each)
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
        //Add the difference to our last temp value
        temp += sunIntensity
        atmosTemp += atmosphericTemperature

       
        //Round to the Hundredths place
        temp = roundToTenths(num: temp)
        if(temp < -25){
            temp = -25
        }
        else if(temp > 10){
            temp = 10
        }
        sunLabel.text = String("Mean Air Temp = " + String(describing: temp) + " °C")
        sunLabel.sizeToFit()
        
        atmosTemp = roundToTenths(num: atmosTemp)
        if(atmosTemp < 0){
            atmosTemp = 0
        }
        else if(atmosTemp > 25){
            atmosTemp = 25
        }
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
                
                //have to take into account the line heights into the height bound, or else previous view will be smaller than planned
                let groundLayerHeightBound: CGFloat = maxGroundHeight - maxOrganicLayerHeight - view.frame.height - staticLineGround.frame.height //get 15% of screen for roots maxGroundHeight -
                
                var newImageViewHeight = screenHeight - (newLineYValue + view.frame.height)
                
                var previousViewHeight: CGFloat = (previousView?.frame.height)!

                let validMovement = getMovement(previousViewMinY: staticGroundLayer.frame.minY, previousViewHeight: staticGroundLayer.frame.height, previousHeightBound: 0.0, heightBound: groundLayerHeightBound, newLineYValue: &newLineYValue, viewHeight: view.frame.height, followingMinY: screenHeight, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)

                view.frame = CGRect(origin: CGPoint(x: lineGround.frame.minX, //only move vertically, don't change x
                    y: newLineYValue), size: CGSize(width: lineGround.frame.width, height: lineGround.frame.height))
                
                groundImageView.frame = CGRect(origin: CGPoint(x: view.center.x - groundImageView.frame.width/2, y: newLineYValue + lineGround.frame.height), size: CGSize(width: (groundImageView.frame.width),height: newImageViewHeight))
                staticGroundLayer.frame = CGRect(origin: CGPoint(x: staticGroundLayer.frame.minX, y: staticGroundLayer.frame.minY), size: CGSize(width: (staticGroundLayer.frame.width),height: previousViewHeight))
                
                //Re-draw label with new coordinates
                if(validMovement){
                    var num = getUnits(topAverageValue: groundTopAverageValue, maxValue: groundMaxUnitHeight, maxHeight: maxOrganicLayerHeight, newHeight: previousViewHeight, percentage: 0.0) //groundHeightPercentage)

                    num = roundToHundredths(num: num)
                    groundLevel = num

                    if(groundLevel < 0.0001){
                        Hv = 0.0 
                        groundLabel.text = "No Organic"
                    }else{
                        Hv = Double(num)
                        groundLabel.text = "Organic Layer Thickness = " + String(describing: num) + " m"
                    }
                    groundLabel.sizeToFit()
                    drawPermafrost()
                }
                
                let groundLabelNewX: CGFloat = staticGroundLayer.frame.maxX - groundLabel.frame.width - padding/4
                let groundLabelNewY: CGFloat = padding/4
                groundLabel.frame = CGRect(origin: CGPoint(x: groundLabelNewX, y: groundLabelNewY), size: CGSize(width: groundLabel.frame.width, height: groundLabel.frame.height))
                
                permafrostLabel.frame = CGRect(origin: CGPoint(x: groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4, y: permafrostLabel.frame.origin.y), size: CGSize(width: permafrostLabel.frame.width, height: permafrostLabel.frame.height))
                
                
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
                
                let validMovement = getMovement(previousViewMinY: skyView.frame.minY, previousViewHeight: skyView.frame.height, previousHeightBound: skyViewHeightBound, heightBound: heightBound, newLineYValue: &newLineYValue, viewHeight: view.frame.height, followingMinY: staticLineGround.frame.minY, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)
                
                view.frame = CGRect(origin: CGPoint(x: snowLineView.frame.minX, //only move vertically, don't change x
                    y: newLineYValue), size: CGSize(width: snowLineView.frame.width, height: snowLineView.frame.height))
                
                snowImageView.frame = CGRect(origin: CGPoint(x: view.center.x - snowImageView.frame.width/2, y: newLineYValue + snowLineView.frame.height), size: CGSize(width: (snowImageView.frame.width),height: newImageViewHeight))
                skyView.frame = CGRect(origin: CGPoint(x: (skyView.frame.minX), y: (skyView.frame.minY)), size: CGSize(width: (skyView.frame.width), height: previousViewHeight))
                
                //Update label
                sunLabel.sizeToFit()
   
                //y grows down, but in the app we want it to grow up
                
                snowLabel.frame = CGRect(origin: CGPoint(x: snowLabel.frame.minX, y: previousViewHeight - snowLabel.frame.height - padding/4), size: CGSize(width: snowLabel.frame.width, height: snowLabel.frame.height))
                
                
                //only update the snow level if the movement is valid
                if(validMovement){
                    
                    Hs = Double(getUnits(topAverageValue: 1.0, maxValue: 5.0, maxHeight: maxSnowHeight, newHeight: newImageViewHeight, percentage: 0.66))
                    Hs = Double(roundToHundredths(num: CGFloat(Hs)))
                    
                    if(Hs == 0.0){
                        snowLabel.text = "No Snow"
                        snowLabel.sizeToFit()
                    }
                    else{
                        snowLabel.text = "Snow Height = " + String(describing: Hs) + " m"
                        snowLabel.sizeToFit()
                    }

                    drawPermafrost()
                }
            }
            
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
        /*
        let aTemp = "A"
        let subATemp = "t"
        let restOfString = " = " + String(describing: newText) + " °C"
        let bigFont = UIFont(name: "Helvetica", size: 17)
        let smFont = UIFont(name: "Helvetica", size: 14)
        atmosphericTempLabel.attributedText = subscriptTheString(str: aTemp, toSub: subATemp, strAtEnd: restOfString, bigFont: bigFont!, smallFont: smFont!) */
        
        atmosphericTempLabel.text = "Air Temp Amplitude = " + newText + " °C"
        atmosphericTempLabel.sizeToFit()
    }
    
    func drawPermafrost(){

        updatePermafrostLabel()

        //the maximum the permafrost line can go to not interfere with bottom labels
        let maxY = screenHeight - padding // permafrostLabel.frame.minY - padding/4
        
        //the minimum the permafrost line can go (ground)
        let minY = staticLineGround.frame.maxY
    
        //the permafrost line will line up with the organic layer thickness (up to 0.25 on screen)
        //then it will expand by 1m/screenUnit until max
        
        
        let maxHeight = maxY - minY

        let maxVal:CGFloat = 2.0 // change later - stakeholder TODO //////////////////////////////////////////////////////////

        //get substring to turn into number
        let start = permafrostLabel.text?.index((permafrostLabel.text?.startIndex)!, offsetBy: 6)
        let end = permafrostLabel.text?.index((permafrostLabel.text?.endIndex)!, offsetBy: -2)
        let substr = permafrostLabel.text?[start!..<end!] //.substringWith(start: start, end: end)

        let permafrostUnitsString = String(substr!)

        if let temp = NumberFormatter().number(from: permafrostUnitsString){
            
            let permafrostMeterValue = CGFloat(truncating: temp)
            var height: CGFloat = 0
            //calculate where the line should be drawn
            if(permafrostMeterValue < groundMaxUnitHeight){
                height = permafrostMeterValue *  maxOrganicLayerHeight / groundMaxUnitHeight
            }
            else{
                
                height = permafrostMeterValue * (maxHeight - maxOrganicLayerHeight)/maxVal + maxOrganicLayerHeight
            }
            
            let yPos = height + minY //the actual y value on the screen
            let rect = CGRect(origin: CGPoint(x: permafrostImageView.frame.minX, y: yPos), size: CGSize(width: UIScreen.main.bounds.width, height: permafrostImageView.frame.height))
            permafrostImageView.frame = rect

        }
        else{
            let rect = CGRect(origin: CGPoint(x: permafrostImageView.frame.minX, y: minY), size: CGSize(width: UIScreen.main.bounds.width, height: permafrostImageView.frame.height))
            permafrostImageView.frame = rect
        }
        
        

        updatePermafrostLabel()

    }

}


