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
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var atmosphericTempLabel: UILabel!
    
    //The sun itself
    @IBOutlet weak var sunView: UIImageView!
    
    //Snow Image View
    @IBOutlet weak var snowLineView: UIImageView!
    @IBOutlet weak var snowImageView: UIView!
    @IBOutlet weak var snowLabel: UILabel!
    
    //Middle solid line that determines ground level of 0
    @IBOutlet weak var staticLineGround: UIImageView!
    
    //The roots/organic layer view and label
    @IBOutlet weak var organicLayer: UIView!
    @IBOutlet weak var groundLabel: UILabel!
    
    //Mineral layer
    @IBOutlet weak var lineGround: UIImageView!
    @IBOutlet weak var groundImageView: UIView!
    
    //Permafrost Layer
    var permafrostLabel: UILabel
    var permafrostImageView: UIImageView
    
    //Ground Temperature Label
    var groundTempLabel: UILabel
    
    //Padding is for drawing within a view so it's not touching the edges (labels)
    var padding: CGFloat = 40.0

    //Get the max heights of this particular screen(calculated on every device)
        //This is for drawing purposes and setting the units, device independent
    var maxSnowHeight: CGFloat
    var maxGroundHeight: CGFloat
    var maxOrganicLayerHeight: CGFloat
    var groundMaxUnitHeight: CGFloat //the maximum height for the roots in units (0.25m)
    //Screen size
    var screenHeight: CGFloat
    var screenWidth: CGFloat
    var navBar: UINavigationBar
    
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
    var Hv: Double //organic layer thickness
    var Cs: Double //volumetric heat capacity of snow
    var Tgs: Double //Mineral layer temperature
    var eta: Double //Volumetric water content
    var Ks: Double //Thermal conductivity of snow
    var Tair: CGFloat //Mean Annual temperature
    var Aair : CGFloat //Amplitude of the air temperature
    var ALT: CGFloat //Active Layer Thickness

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
        navBar = UINavigationBar()
        screenHeight = UIScreen.main.bounds.height // - navBar.frame.height
        screenWidth = UIScreen.main.bounds.width

        //max image view heights
        maxSnowHeight = 0.0
        maxGroundHeight = 0.0
        groundMaxUnitHeight = 0.25
        maxOrganicLayerHeight = (screenHeight * 0.15)
        
        //where the screen is split between ground and sky
        heightBasedOffPercentage = screenHeight * (0.5)
        
        //the permafrost view - where the line marking the permafrost lives
        permafrostImageView = UIImageView(image: UIImage(named: "PermafrostLine"))
        
        //Labels
        permafrostLabel = UILabel()
        groundTempLabel = UILabel()
        
        
        //Our inputs for our permafrost formula
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
        eta = 0.45 //Volumetric water content - porosity
        Ks = 0.15 //Thermal conductivity of snow
        Hv = 0.25 //organic layer thickness
        ALT = 0 //our ALT in meters
        Tair = 10.0 //Mean annual air temperature
        Aair = 25.0 //Amplitude of the air temperature

        
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
        
        //make the background/underneath view a sky color
        self.view.backgroundColor = UIColor(red: 0, green: 191/255, blue: 255/255, alpha: 1.0)
        
        //Initialize Temperature Label (Mean Temperature)
        tempLabel.text = "Mean Air Temp = " + String(describing: Tair) + " °C"
        tempLabel.sizeToFit()
        tempLabel.backgroundColor = .white
        
        //Atmospheric Temperature
        updateAairLabel(newText: String(describing: Aair))
        atmosphericTempLabel.backgroundColor = .white 

        //Set the backgrounds of the views
        snowImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Snow")!)
        organicLayer.backgroundColor = UIColor(patternImage: UIImage(named: "Ground")!)
        groundImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Empty")!)

        //Initialize Labels
            //Have white "boxes" around the labels for better text readability
        snowLabel.backgroundColor = .white
        snowLabel.text = "Snow Height = " + String(describing: Hs) + " m"
        snowLabel.sizeToFit()
        
        groundLabel.text = "Organic Layer Thickness = " + String(describing: Hv) + " m"
        groundLabel.backgroundColor = .white
        groundLabel.sizeToFit()
        
        permafrostLabel.text = "Active Layer Thickness = " + String(describing: ALT) + " m"
        permafrostLabel.backgroundColor = .white
        permafrostLabel.sizeToFit()
        
        groundTempLabel.text = "Mean Annual Ground Temp = " + String(describing: Tgs) + " °C"
        groundTempLabel.backgroundColor = .white
        groundTempLabel.sizeToFit()
        
        drawPermafrost()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        draw()
    }
    
    //Draw our views programmatically based on our screen size
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
       
        //make transparent
        skyView.backgroundColor = UIColor(white: 1, alpha: 0)
        let sunViewSize: CGFloat = skyView.frame.width/3
        
        sunView.frame = CGRect(origin: CGPoint(x:skyView.frame.width - sunViewSize, y: padding/2), size: CGSize(width: sunViewSize, height: sunViewSize))

        staticLineGround = changeViewsYValue(view: staticLineGround, newX: 0.0, newY: heightBasedOffPercentage) as! UIImageView

        snowImageView = changeViewsYValue(view: snowImageView, newX: 0.0, newY: staticLineGround.frame.minY - snowImageView.frame.height)
        
        snowLineView = changeViewsYValue(view: snowLineView, newX: 0.0, newY: snowImageView.frame.minY - snowLineView.frame.height) as! UIImageView
        
        organicLayer = changeViewsYValue(view: organicLayer, newX: 0.0, newY: staticLineGround.frame.maxY)
        lineGround = changeViewsYValue(view: lineGround, newX: 0.0, newY: organicLayer.frame.maxY) as! UIImageView
        groundImageView = changeViewsYValue(view: groundImageView, newX: 0.0, newY: lineGround.frame.maxY)
        
        staticLineGround = changeViewsYValue(view: staticLineGround, newX: 0.0, newY: heightBasedOffPercentage) as! UIImageView
        
        //Make the Sun in its own view
        skyView.frame = CGRect(origin: CGPoint(x: 0.0, y:0.0), size: CGSize(width: screenWidth, height: screenHeight -  snowImageView.frame.minY - snowLineView.frame.height))

    }
    
    //Draw the label locations initially
    func drawInitLabels(){
        //Aair label
        atmosphericTempLabel.frame.origin = CGPoint(x: skyView.frame.minX + padding/2, y: sunView.frame.minY)
        //Tair
        tempLabel.frame.origin = CGPoint(x: skyView.frame.minX + padding/2, y: sunView.frame.minY + tempLabel.frame.height + padding/4)
        //Snow
        snowLabel.frame.origin = CGPoint(x: skyView.frame.maxX - snowLabel.frame.width - padding/4, y: skyView.frame.height - snowLabel.frame.height - padding/4)
        //Organic
        groundLabel.frame.origin = CGPoint(x: organicLayer.frame.maxX - groundLabel.frame.width - padding/4, y: padding/4)
        //ALT
        permafrostLabel.frame.origin = CGPoint(x:  groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4 , y: self.view.frame.maxY - permafrostLabel.frame.height - padding/4)
        //Tgs
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
        ALT = CGFloat(computePermafrost(Kvf: Kvf, Kvt: Kvt, Kmf: Kmf, Kmt: Kmt, Cmf: Cmf, Cmt: Cmt, Cvf: Cvf, Cvt: Cvt, Hs: Hs, Hv: Hv, Cs: Cs, Tgs: &Tgs, tTemp: Double(Tair), aTemp: Double(Aair), eta: eta, Ks: Ks))
        if(ALT.isNaN){
            //alert the user that this is not valid inputs (air temperatures are
        }
        //update the display
        ALT = roundToHundredths(num: ALT)
        permafrostLabel.text = "Active Layer Thickness = " + String(describing: ALT) + " m"
        permafrostLabel.sizeToFit()
        
        //update ground temperature label
        Tgs = Double(roundToHundredths(num: CGFloat(Tgs)))
        groundTempLabel.text = "Mean Annual Ground Temp = " + String(describing: Tgs) + " °C"
        groundTempLabel.sizeToFit()
        
        //if label is to intersect other labels so it is unreadable - go to the bottom of the screen
        var newY = permafrostImageView.frame.maxY + padding/4
        var groundY = groundImageView.frame.minY + padding/4 //+ 44.0
        var groundFrame = groundLabel.frame
        print("organic thickness label: " + String(describing: groundY))
        groundFrame.origin = CGPoint(x: 0, y: groundY)
        print("groundFrame maxY: " + String(describing: groundFrame.maxY))
        print("groundFrame height: " + String(describing: groundFrame.height))
        print("Staticlineground: " + String(describing: staticLineGround.frame.minY))
        
        if(intersects(newY: newY, label: permafrostLabel, frames: [groundFrame, groundTempLabel.frame])){
            print(String(describing: permafrostLabel.frame.minY) + " max: " + String(describing: permafrostLabel.frame.maxY))
            print("intersects")
            print(groundFrame)
            print(groundTempLabel.frame)
            //it intersects a label
            newY = groundTempLabel.frame.maxY + padding/4
        }
         permafrostLabel.frame = CGRect(origin: CGPoint(x: groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4, y: newY), size: CGSize(width: permafrostLabel.frame.width, height: permafrostLabel.frame.height))
 }
    
    func intersects(newY: CGFloat, label: UILabel, frames: [CGRect])->Bool{
        let maxY = newY + label.frame.height
        for f in frames {
            if (maxY > f.minY && newY < f.minY) || (newY <= f.maxY && maxY >= f.maxY){
                //it intersects
                return true
            }
        }
        return false
    }
    
    //Snow layer was tapped - display values for entering
    @IBAction func snowLayerTapGesture(_ sender: UITapGestureRecognizer){
        //make popup
        let textBoxPopup = PopUpView()
        textBoxPopup.addTitle(title: "Snow Layer")
        textBoxPopup.addTitle(title: "Volumetric Heat Capacity of Snow")
        
        //Cs
        textBoxPopup.addTextField(text: String(Cs), tag: 0)
        
        //Ks
        textBoxPopup.addTitle(title: "Thermal Conductivity of Snow")
        textBoxPopup.addTextField(text: String(Ks), tag: 1)
        
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
        checkIfValidNumber(tag: 1, variable: &Ks, errorMessage: "Invalid Ks", dict: &dict)
        
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
    
    @IBAction func organicLayerTapGesture(_ sender: UITapGestureRecognizer) {
        
        //Make a new popup - give position on screen x & y
        let textBoxPopup = PopUpView()
        //set background color
        textBoxPopup.setBackGroundColor(color: UIColor(white: 1, alpha: 1))
        //add title to top
        textBoxPopup.addTitle(title: "Organic Layer")
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
        
        textBoxPopup.addTitle(title: "Mineral Layer")
        textBoxPopup.addTitle(title: "Porosity")
        textBoxPopup.addTextField(text: String(eta), tag: 0)
        
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
        
        checkIfValidNumber(tag: 0, variable: &eta, errorMessage: "Invalid Porosity", dict: &dict)
        //Porosity is between 0 and 1
        if(eta > 1){
            eta = 1
            createAlert(title: "Input Error", errorMessage: "Invalid Porosity value. Should be between 0 and 1.")
        }
        else if(eta < 0){
            eta = 0
        }
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
    
    func createAlert(title: String, errorMessage: String){
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        let unitPerMovement:CGFloat = 1/10.0

        
        //Get the movement difference in degrees
        var temp = unitPerMovement * translation.x
        var atmosTemp = unitPerMovement * translation.y
        //The temperature is subtracting from the sun intensity
        atmosTemp = atmosTemp * -1
        //Add the difference to our last temp value
        temp += Tair
        atmosTemp += Aair

       
        //Round to the Hundredths place
        temp = roundToTenths(num: temp)
        if(temp < -25){
            temp = -25
        }
        else if(temp > 10){
            temp = 10
        }
        tempLabel.text = String("Mean Air Temp = " + String(describing: temp) + " °C")
        tempLabel.sizeToFit()
        
        atmosTemp = roundToTenths(num: atmosTemp)
        if(atmosTemp < 0){
            atmosTemp = 0
        }
        else if(atmosTemp > 25){
            atmosTemp = 25
        }
        updateAairLabel(newText: String(describing: atmosTemp))
        
        //If the user has let go
        if recognizer.state == UIGestureRecognizerState.ended {
            Tair = temp
            Aair = atmosTemp
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
                let previousView = organicLayer
                //How small the static ground plant layer image is allowed to be
                let screenHeight = UIScreen.main.bounds.height
                
                //have to take into account the line heights into the height bound, or else previous view will be smaller than planned
                let groundLayerHeightBound: CGFloat = maxGroundHeight - maxOrganicLayerHeight - view.frame.height - staticLineGround.frame.height //get 15% of screen for roots maxGroundHeight -
                
                var newImageViewHeight = screenHeight - (newLineYValue + view.frame.height)
                
                var previousViewHeight: CGFloat = (previousView?.frame.height)!

                let validMovement = getMovement(previousViewMinY: organicLayer.frame.minY, previousViewHeight: organicLayer.frame.height, previousHeightBound: 0.0, heightBound: groundLayerHeightBound, newLineYValue: &newLineYValue, viewHeight: view.frame.height, followingMinY: screenHeight, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)

                view.frame = CGRect(origin: CGPoint(x: lineGround.frame.minX, //only move vertically, don't change x
                    y: newLineYValue), size: CGSize(width: lineGround.frame.width, height: lineGround.frame.height))
                
                groundImageView.frame = CGRect(origin: CGPoint(x: view.center.x - groundImageView.frame.width/2, y: newLineYValue + lineGround.frame.height), size: CGSize(width: (groundImageView.frame.width),height: newImageViewHeight))
                organicLayer.frame = CGRect(origin: CGPoint(x: organicLayer.frame.minX, y: organicLayer.frame.minY), size: CGSize(width: (organicLayer.frame.width),height: previousViewHeight))
                
                //Re-draw label with new coordinates
                if(validMovement){
                    var num = getUnits(topAverageValue: 0, maxValue: groundMaxUnitHeight, maxHeight: maxOrganicLayerHeight, newHeight: previousViewHeight, percentage: 0.0)

                    num = roundToHundredths(num: num)
                    Hv = Double(num)

                    if(Hv < 0.0001){
                        Hv = 0.0 
                        groundLabel.text = "No Organic"
                    }else{
                        groundLabel.text = "Organic Layer Thickness = " + String(describing: Hv) + " m"
                    }
                    groundLabel.sizeToFit()
                    drawPermafrost()
                }
                
                let groundLabelNewX: CGFloat = organicLayer.frame.maxX - groundLabel.frame.width - padding/4
                let groundLabelNewY: CGFloat = padding/4
                groundLabel.frame = CGRect(origin: CGPoint(x: groundLabelNewX, y: groundLabelNewY), size: CGSize(width: groundLabel.frame.width, height: groundLabel.frame.height))
                

                drawPermafrost()
                
                
            }
            //We are moving the snow layer
            else if view == snowLineView {
                let previousView = skyView
                //How small the static ground plant layer image is allowed to be
   
                let skyViewHeightBound: CGFloat = sunView.frame.maxY + tempLabel.frame.height + padding/2
                let heightBound: CGFloat = 0.0
                var newImageViewHeight = staticLineGround.frame.minY - (newLineYValue + view.frame.height)
                
                var previousViewHeight: CGFloat = (previousView?.frame.height)!
                
                let validMovement = getMovement(previousViewMinY: skyView.frame.minY, previousViewHeight: skyView.frame.height, previousHeightBound: skyViewHeightBound, heightBound: heightBound, newLineYValue: &newLineYValue, viewHeight: view.frame.height, followingMinY: staticLineGround.frame.minY, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)
                
                view.frame = CGRect(origin: CGPoint(x: snowLineView.frame.minX, //only move vertically, don't change x
                    y: newLineYValue), size: CGSize(width: snowLineView.frame.width, height: snowLineView.frame.height))
                
                snowImageView.frame = CGRect(origin: CGPoint(x: view.center.x - snowImageView.frame.width/2, y: newLineYValue + snowLineView.frame.height), size: CGSize(width: (snowImageView.frame.width),height: newImageViewHeight))
                skyView.frame = CGRect(origin: CGPoint(x: (skyView.frame.minX), y: (skyView.frame.minY)), size: CGSize(width: (skyView.frame.width), height: previousViewHeight))
                
                //Update label
                tempLabel.sizeToFit()
   
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
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        //if the next view is our location table view
        guard let locationTableViewController = segue.destination as? LocationTableViewController else {
            fatalError("Expected destination: \(segue.destination)")
        }
        //send the location created by the user using the UI in case the user wants to make a new one
        locationTableViewController.uiLocation = Location(name: "current", Kvf: Kvf, Kvt: Kvt, Kmf: Kmf, Kmt: Kmt, Cmf: Cmf, Cmt: Cmt, Cvf: Cvf, Cvt: Cvt, Hs: Hs, Hv: Hv, Cs: Cs, Tgs: Tgs, eta: eta, Ks: Ks, Tair: Double(Tair), Aair: Double(Aair), ALT: Double(ALT)) ?? Location()
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
        updateAairLabel()
        ````
    */
    func updateAairLabel(newText: String){
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
        let maxY = screenHeight - padding/2 - (groundLabel.frame.height * 2) //+ navBar.frame.height  // permafrostLabel.frame.minY - padding/4
 
        //the minimum the permafrost line can go (ground)
        let minY = staticLineGround.frame.maxY // + (navBar.frame.height * 2)  //nav bar height
        
        print("lineground: " + String(describing: lineGround.frame.maxY))
        print("staticLineGroundmaxY: " + String(describing: minY))
        print("Screenheight: " + String(describing: screenHeight))
        print("groundlabel: " + String(describing: groundLabel.frame.minY))
        

        //the permafrost line will line up with the organic layer thickness (up to 0.25 on screen)
        //then it will expand by 1m/screenUnit until max
        
        
        let maxHeight = maxY - minY

        let maxVal:CGFloat = 2.0 // change later - stakeholder TODO //////////////////////////////////////////////////////////

        var height: CGFloat = 0
        //calculate where the line should be drawn
        if(ALT < groundMaxUnitHeight){
            height = ALT *  maxOrganicLayerHeight / groundMaxUnitHeight
        }
        else{
            height = ALT * (maxHeight - maxOrganicLayerHeight)/maxVal + maxOrganicLayerHeight
        }
        let yPos = height + minY //the actual y value on the screen
        print("new y pos of Pline: " + String(describing: yPos))
        let rect = CGRect(origin: CGPoint(x: permafrostImageView.frame.minX, y: yPos), size: CGSize(width: UIScreen.main.bounds.width, height: permafrostImageView.frame.height))
        permafrostImageView.frame = rect

        updatePermafrostLabel()

    }

}


