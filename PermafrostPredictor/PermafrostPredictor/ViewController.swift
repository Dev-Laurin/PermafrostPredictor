//
//  ViewController.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 2/28/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit
import os

/**
    Our one-page app. This is where everything happens, the view controller.
*/
class ViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationItem!
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
    private var permafrostLabel: UILabel
    private var permafrostImageView: UIImageView
    
    //Ground Temperature Label
    private var groundTempLabel: UILabel
    
    //Padding is for drawing within a view so it's not touching the edges (labels)
    private var padding: CGFloat = 40.0

    //Get the max heights of this particular screen(calculated on every device)
        //This is for drawing purposes and setting the units, device independent
    private var maxSnowHeight: CGFloat
    private var maxGroundHeight: CGFloat
    private var maxOrganicLayerHeight: CGFloat
    private var groundMaxUnitHeight: CGFloat //the maximum height for the roots in units (0.25m)
    //Screen size
    var screenHeight: CGFloat
    var screenWidth: CGFloat
    
    //Split snow & ground to 50% of screen
    private var heightBasedOffPercentage : CGFloat //screen grows down
    
    //Inputs for permafrost levels
    private var Kvf: Double
    private var Kvt: Double
    private var Kmf: Double
    private var Kmt: Double
    private var Cmf: Double
    private var Cmt: Double
    private var Cvf: Double
    private var Cvt: Double
    private var Hs: Double
    private var Hv: Double //organic layer thickness
    private var Cs: Double //volumetric heat capacity of snow
    private var Tgs: Double //Mineral layer temperature
    private var eta: Double //Volumetric water content
    private var Ks: Double //Thermal conductivity of snow
    private var Tair: CGFloat //Mean Annual temperature
    private var Aair : CGFloat //Amplitude of the air temperature
    private var ALT: CGFloat //Active Layer Thickness
    
    //Our location object so we can pass our values and load other locations from this UI easily
    var location: Location
    
    //where the view actually starts being drawn (taking out the navbar)
    private var zeroInView: CGFloat
    
    //Keep track of the info popup - is it visible or not?
    private var infoShowing: Bool
    private var sidebar: UIView

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
        //default
        location = Location()

        //screen size
        screenHeight = UIScreen.main.bounds.height 
        screenWidth = UIScreen.main.bounds.width

        //max image view heights - some of these will change later
        maxSnowHeight = 0.0  //changes later when the views load according to storyboard
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
        Cmf = 2 //Volumetric heat capacity of frozen soil
        Cmt = 3 //Volumetric heat capacity of thawed soil
        Cvf = 1 //Volumetric heat capacity of frozen moss
        Cvt = 2 //Volumetric heat capacity of thawed moss
        Hs = 0.3  //Snow height
        Hv = 0.25 //Thickness of vegetation
        Cs = 0.5 //Volumetric heat capacity of snow
        Tgs = 0 //Mean annual temperature at the top of mineral layer
        eta = 0.45 //Volumetric water content - porosity
        Ks = 0.15 //Thermal conductivity of snow
        Hv = 0.25 //organic layer thickness
        ALT = 0 //our ALT in meters
        Tair = 10.0 //Mean annual air temperature
        Aair = 25.0 //Amplitude of the air temperature
        
        //Wait until views are loaded to set real value
        zeroInView = 0
        
        //info popup box
        infoShowing = false
        
        //create a new view that is like a sidebar
        sidebar = UIView()
        
        //Call the super version, recommended
        super.init(coder: coder )!
       //Call our function when the app goes into the background so we can save our configuration
        NotificationCenter.default.addObserver(self, selector: #selector(suspending), name: .UIApplicationWillResignActive, object: nil)
    }
    
    /**
     The app is suspending, save the location previously loaded in the ui so the user can pick up where they left off.
    */
    @objc func suspending(_ notification: Notification){
        saveUILocation()
    }
    
    //MARK: viewDidLoad()
    /**
     The view loaded, load the old location the user last used. Init views.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if the user had manipulated the UI before - load the last configuration
        if let savedLocation = loadLocation() {
            location = savedLocation[0] //only 1 is saved but it returns an array
        }
        
        view.addSubview(permafrostImageView)
        view.addSubview(permafrostLabel)
        view.addSubview(groundTempLabel)
        
        //make the background/underneath view a sky color
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Sky")!)//UIColor(red: 0, green: 191/255, blue: 255/255, alpha: 1.0)
        
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
        
        //update the permafrost view
        drawPermafrost()
        
        //The navigation bar size for some of the views for drawing
        var barHeight: CGFloat = 44.0
        if let navBarHeight: CGFloat = (self.navigationController?.navigationBar.frame.height){
            barHeight = navBarHeight
        }
        else {
            barHeight = 44.0
        }
        
        //the actual 'zero' in the view if we discount the navbar
        zeroInView = barHeight + padding/2
    }
    
    /**
        The view has appeared - the views are done loading and drawing in the correct places. Now we can set the views to their real positions based on a save location.
    */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        draw() //set initial
        
        //if the user was working on a location last time that was saved - load that into the UI to continue
        if(location != Location()) {
            loadUI()
        }
        
    }
    
    //Draw our views programmatically based on our screen size
    /**
        To initialize our drawing of the views. We initialize the view placement themselves based on the device's dimensions, as well as initialize the labels and the maximum drawing variables for when we re-draw later.
    */
    private func draw(){
        //Draw initial here
        drawInitViews()
        //put labels in initial spots
        drawInitLabels()
        //Get the maximum our view heights can be based on this screen/device
        findMaxHeightsBasedOnScreen()
    }
    
    /**
        Draw the views initially with respect to each other (non-overlapping)
    */
    private func drawInitViews(){
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
        
        groundImageView.frame = CGRect(origin: CGPoint(x: 0.0, y: lineGround.frame.maxY), size: CGSize(width: screenWidth, height: screenHeight - lineGround.frame.maxY))

        staticLineGround = changeViewsYValue(view: staticLineGround, newX: 0.0, newY: heightBasedOffPercentage) as! UIImageView
        
        //Make the Sun in its own view
        skyView.frame = CGRect(origin: CGPoint(x: 0.0, y:0.0), size: CGSize(width: screenWidth, height: screenHeight -  snowImageView.frame.minY - snowLineView.frame.height))
        
        //Make Info sidebar view
        sidebar.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: screenWidth/2, height: screenHeight))
        let gi_logo = UIImageView(image: UIImage(named: "GI_Logo"))
        let logoWidth = screenWidth/2 - padding/2
        gi_logo.frame = CGRect(origin: CGPoint(x: padding/4, y: screenHeight - padding/4 - logoWidth), size: CGSize(width: logoWidth, height: logoWidth))
        sidebar.addSubview(gi_logo)
        sidebar.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        
        let copyrightGIUAF = UILabel()
        copyrightGIUAF.text = "©2018 Geophysical Institute, University of Alaska Fairbanks. \n\nDesigned and Conceived by Dmitry Nicolsky who is apart of the Snow, Ice, and Permafrost research group at the GI. \n\nDeveloped by Laurin Fisher."
        copyrightGIUAF.textColor = .white
        copyrightGIUAF.sizeToFit()
        
        //Dynamically wrapping
        copyrightGIUAF.lineBreakMode = .byWordWrapping
        copyrightGIUAF.numberOfLines = 0
        
        //set the size
        var infoStartingY:CGFloat = 40
        copyrightGIUAF.frame = CGRect(origin: CGPoint(x: padding/4, y: infoStartingY), size: CGSize(width: sidebar.frame.width - padding/2, height: sidebar.frame.height - infoStartingY - (3*padding/4) - gi_logo.frame.height))
        sidebar.addSubview(copyrightGIUAF)
        
        sidebar.frame.origin = CGPoint(x: -sidebar.frame.width, y: 0)
        view.addSubview(sidebar)
    }
    
    /**
     Draw the label locations initially
    */
    private func drawInitLabels(){
        //Aair label
        atmosphericTempLabel.frame.origin = CGPoint(x: skyView.frame.minX + padding/2, y: sunView.frame.minY)
        //Tair
        tempLabel.frame.origin = CGPoint(x: skyView.frame.minX + padding/2, y: sunView.frame.minY + tempLabel.frame.height + padding/4)
        //Snow
        snowLabel.frame = CGRect(origin: CGPoint(x: skyView.frame.maxX - snowLabel.frame.width - padding/4, y: snowLineView.frame.minY - padding/4 - snowLabel.frame.height), size: CGSize(width: snowLabel.frame.width, height: snowLabel.frame.height))
        //Organic
        groundLabel.frame.origin = CGPoint(x: organicLayer.frame.maxX - groundLabel.frame.width - padding/4, y: padding/4)
        //ALT
        permafrostLabel.frame.origin = CGPoint(x:  groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4 , y: self.view.frame.maxY - permafrostLabel.frame.height - padding/4)
        //Tgs
        groundTempLabel.frame.origin = CGPoint(x:  groundImageView.frame.maxX - groundTempLabel.frame.width - padding/4, y: permafrostLabel.frame.minY  - groundTempLabel.frame.height - padding/4 )
    }
    
    /**
        Find the maximums for the snow and ground layers.
    */
    private func findMaxHeightsBasedOnScreen(){
        let screenHeight = UIScreen.main.bounds.height
        
        //How much can snow grow based on sun?
        var minimumHeight = sunView.frame.minY + sunView.frame.height + snowLabel.frame.height + padding/2
        minimumHeight += padding/4
        //minimumHeight is the minimum Height we have to draw the top elements
        maxSnowHeight = heightBasedOffPercentage - minimumHeight
        
        maxGroundHeight = screenHeight - heightBasedOffPercentage //the minimum the grey view can be
    }
    
    /**
        Run the algorithm to find the permafrost depth and the ground temperature. Update the permafrost labels with the new values.
    */
    private func updatePermafrostLabel(){
        //update the value
        ALT = CGFloat(computePermafrost(Kvf: Kvf, Kvt: Kvt, Kmf: Kmf, Kmt: Kmt, Cmf: (Cmf * 1000000), Cmt: (Cmt * 1000000), Cvf: (Cvf * 1000000), Cvt: (Cvt * 1000000), Hs: Hs, Hv: Hv, Cs: (Cs * 1000000), magt: &Tgs, tTemp: Double(Tair), aTemp: Double(Aair), eta: eta, Ks: Ks))
        
        //update the display
        ALT = round(num: ALT, format: ".2")
        permafrostLabel.text = "Active Layer Thickness = " + String(describing: ALT) + " m"
        permafrostLabel.sizeToFit()
        
        //update ground temperature label
        if(Tgs.isNaN){
            groundTempLabel.text = "Mean Annual Ground Temp = " + "NaN" + " °C"
        }
        else {
            Tgs = Double(round(num: CGFloat(Tgs), format: ".2"))
            groundTempLabel.text = "Mean Annual Ground Temp = " + String(describing: Tgs) + " °C"
            groundTempLabel.sizeToFit()
        }
        
        //if label is to intersect other labels so it is unreadable - go to the bottom of the screen
        var newY = permafrostImageView.frame.maxY + padding/4
        let groundY = groundImageView.frame.minY + groundLabel.frame.minY + zeroInView
        var groundFrame = groundLabel.frame
        
        groundFrame.origin = CGPoint(x: 0, y: groundY)

        if(intersects(newY: newY, label: permafrostLabel, frames: [groundFrame, groundTempLabel.frame])){
            //it intersects a label
            newY = groundTempLabel.frame.maxY + padding/4
        }
         permafrostLabel.frame = CGRect(origin: CGPoint(x: groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4, y: newY), size: CGSize(width: permafrostLabel.frame.width, height: permafrostLabel.frame.height))
 }
    
    /**
     
    */
    @IBAction func infoButtonPressed(_ sender: UIBarButtonItem) {
        
        //toggle sidebar
        infoShowing = !infoShowing
        if(infoShowing){
            UIView.animate(withDuration: 0.5){
                self.sidebar.center.x += self.sidebar.frame.width
            }
        }
        else{
            UIView.animate(withDuration: 0.5){
                self.sidebar.center.x -= self.sidebar.frame.width
            }
        }
        
    }
    /**
     Snow layer was tapped - display values for entering.
    */
    @IBAction func snowLayerTapGesture(_ sender: UITapGestureRecognizer){
        //make popup
        let textBoxPopup = PopUpView()
        textBoxPopup.addTitle(title: "Snow Layer")
        let bigFont = UIFont(name: "Helvetica", size: 17)!
        let smFont = UIFont(name: "Helvetica", size: 14)!
        let heatCapacityUnits = superscriptTheString(str: "Volumetric Heat Capacity [MJ/m", toSuper: "3", strAtEnd: "/°C]", bigFont: bigFont, smallFont: smFont)
        textBoxPopup.addTitle(title: heatCapacityUnits)
        
        //Cs
        textBoxPopup.addTextField(text: String(Cs), tag: 0)
        
        //Ks
        textBoxPopup.addTitle(title: "Thermal Conductivity [W/m/°C]")
        textBoxPopup.addTextField(text: String(Ks), tag: 1)
        
        textBoxPopup.addButton(buttonText: "Submit", callback: snowPopupSubmitted)
        
        //create a greyed out view to go underneath so user knows this popup is active
        addGreyedOutView()
        
        //resize view to fit elements
        textBoxPopup.resizeView(navBarHeight: zeroInView)
        
        self.view.addSubview(textBoxPopup)
    }
    
    /**
     Popup submit button was pressed for the snow layer. Validate the user input values and update the permafrost views.
     
     -parameter dictionary: A dictionary with key Int and value String. The Int is the tag of the textfields in the popup. The text is the user inputted value.
     
     # Usage Example: #
     ````
     textBoxPopup.addButton(buttonText: "Submit", callback: snowPopupSubmitted)
     //the function gets called later when popup exits
     func snowPopupSubmitted(dictionary: [Int: String]){
        ...
     }
     ````
    */
    private func snowPopupSubmitted(dictionary: [Int: String]){
        var dict = dictionary
        
        //check that the input is valid
        if !checkIfValidNumber(tag: 0, variable: &Cs, errorMessage: "Invalid Cs", dict: &dict) {
            return
        }
        if !checkIfValidNumber(tag: 1, variable: &Ks, errorMessage: "Invalid Ks", dict: &dict) {
            return
        }
        
        drawPermafrost()
    }
    
    /**
        A view that is all grey to cover the screen. Used for when a popup is being displayed. The tag must be 100 for the popup to remove from the superview automatically when the popup exits.
    */
    private func addGreyedOutView(){
        //create a greyed out view to go underneath so user knows this popup is active
        let greyView = UIView()
        greyView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        greyView.frame = self.view.frame
        greyView.tag = 100
        
        self.view.addSubview(greyView)
    }
    
    /**
        The organic layer was tapped - display popup.
    */
    @IBAction func organicLayerTapGesture(_ sender: UITapGestureRecognizer) {
        
        //Make a new popup - give position on screen x & y
        let textBoxPopup = PopUpView()
        //set background color
        textBoxPopup.setBackGroundColor(color: UIColor(white: 1, alpha: 1))
        //add title to top
        textBoxPopup.addTitle(title: "Organic Layer")
        textBoxPopup.addTitle(title: "Thermal Conductivity [W/m/°C]")
        //Kvt - thermal conductivity "thawed" & Kvf - "frozen"
        textBoxPopup.addLabels(text: "thawed", text2: "frozen") //give a storage place for value upon submit
        //Make the editable fields for user input
        textBoxPopup.addTextFields(text: String(Kvt), text2: String(Kvf), outputTag1: 0, outputTag2: 1)
        
        //Volumetric Heat capacity
        let bigFont = UIFont(name: "Helvetica", size: 17)!
        let smFont = UIFont(name: "Helvetica", size: 14)!
        let heatCapacityUnits = superscriptTheString(str: "Volumetric Heat Capacity [MJ/m", toSuper: "3", strAtEnd: "/°C]", bigFont: bigFont, smallFont: smFont)
        textBoxPopup.addTitle(title: heatCapacityUnits)
        //Cvt - "thawed" volumetric heat capacity & Cvf
        textBoxPopup.addLabels(text: "thawed", text2: "frozen")
        //make the fields
        textBoxPopup.addTextFields(text: String(Cvt), text2: String(Cvf), outputTag1: 2, outputTag2: 3)

        //Add submit button
        textBoxPopup.addButton(buttonText: "Submit", callback: popUpButtonPressed)
        
        //resize popup to fit the elements better - cleaner look
        textBoxPopup.resizeView(navBarHeight: zeroInView)
        
        //create a greyed out view to go underneath so user knows this popup is active
        addGreyedOutView()
        self.view.addSubview(textBoxPopup)
    }
    
    /**
        The organic layer popup was submitted/exited. Check inputs and update the permafrost views.
     
     - parameter dictionary: A dictionary with key Int and value String. The Int is the tag of the textfields in the popup. The text is the user inputted value.
    */
    private func popUpButtonPressed(dictionary: [Int: String]){
        
       var dict = dictionary
        //save the values - but test if they can be converted to numbers first
        if !checkIfValidNumber(tag: 0, variable: &Kvt, errorMessage: "Invalid Kvt", dict: &dict) {
            return
        }
        if !checkIfValidNumber(tag: 1, variable: &Kvf, errorMessage: "Invalid Kvf", dict: &dict) {
            return
        }
        if !checkIfValidNumber(tag: 2, variable: &Cvt, errorMessage: "Invalid Cvt", dict: &dict) {
            return
        }
        if !checkIfValidNumber(tag: 3, variable: &Cvf, errorMessage: "Invalid Cvf", dict: &dict) {
            return
        }

        drawPermafrost()
    }
    
    /**
        The mineral layer was tapped (grey bottom most layer). Show the popup with values.
    */
    @IBAction func mineralLayerTapGesture(_ sender: UITapGestureRecognizer){
        let textBoxPopup = PopUpView()
        
        textBoxPopup.addTitle(title: "Mineral Layer")
        
        //Add units to porosity label with superscript
        let bigFont = UIFont(name: "Helvetica", size: 17)!
        let smFont = UIFont(name: "Helvetica", size: 14)!
        let porosityLabel = superscriptTheString(str: "Porosity [m", toSuper: "3", strAtEnd: "/m", bigFont: bigFont, smallFont: smFont)
        let porosityLabelEnding = superscriptTheString(str: "", toSuper: "3", strAtEnd: "]", bigFont: bigFont, smallFont: smFont)
        porosityLabel.append(porosityLabelEnding)
        textBoxPopup.addTitle(title: porosityLabel)
        textBoxPopup.addTextField(text: String(eta), tag: 0)
        
        textBoxPopup.addTitle(title: "Thermal Conductivity [W/m/°C]")
        textBoxPopup.addLabels(text: "thawed", text2: "frozen")
        textBoxPopup.addTextFields(text: String(Kmt), text2: String(Kmf), outputTag1: 1, outputTag2: 2)
        
        let heatCapacityUnits = superscriptTheString(str: "Volumetric Heat Capacity [MJ/m", toSuper: "3", strAtEnd: "/°C]", bigFont: bigFont, smallFont: smFont)
        textBoxPopup.addTitle(title: heatCapacityUnits)
        textBoxPopup.addLabels(text: "thawed", text2: "frozen")
        textBoxPopup.addTextFields(text: String(Cmt), text2: String(Cmf), outputTag1: 3, outputTag2: 4)
        textBoxPopup.addButton(buttonText: "Submit", callback: mineralPopupButtonPressend)
        
        textBoxPopup.resizeView(navBarHeight: zeroInView)
        
        addGreyedOutView()
        self.view.addSubview(textBoxPopup)
    }
    
    /**
        The mineral layer popup was submitted. Check the values and update the permafrost views.
    */
    private func mineralPopupButtonPressend(dictionary: [Int: String]){
        var dict = dictionary
        
        if !checkIfValidNumber(tag: 0, variable: &eta, errorMessage: "Invalid Porosity", dict: &dict) {
            return
        }
        //Porosity is between 0 and 1
        if(eta > 1){
            eta = 1
            createAlert(title: "Input Error", errorMessage: "Invalid Porosity value. Should be between 0 and 1.")
            return
        }
        else if(eta < 0){
            eta = 0
        }
        if !checkIfValidNumber(tag: 1, variable: &Kmt, errorMessage: "Invalid Kmt", dict: &dict) {
            return
        }
        if !checkIfValidNumber(tag: 2, variable: &Kmf, errorMessage: "Invalid Kmf", dict: &dict) {
            return
        }
        if !checkIfValidNumber(tag: 3, variable: &Cmt, errorMessage: "Invalid Cmt", dict: &dict) {
            return
        }
        if !checkIfValidNumber(tag: 4, variable: &Cmf, errorMessage: "Invalid Cmf", dict: &dict){
            return
        }
        
        drawPermafrost()
    }
    
    /**
        Checks if the input given is actually a number. This is used because the textfields have users enter strings, when in reality they should be doubles. Shows an alert box to the user if the input isn't valid.
     
     - parameter tag: The tag of the textfield used in the dictionary.
     - parameter variable: The variable we are saving the value to if it is valid.
     - parameter errorMessage: The message that is displayed in the alert.
     - parameter dict: The dictionary of the textfields' tags and values.
     
     # Usage Example: #
     ````
     //See any of the popupButtonPressed functions for better detail.
     if !checkIfValidNumber(tag: 4, variable: &Cmf, errorMessage: "Invalid Cmf", dict: &dict){
     return
     }
     ````
    */
    private func checkIfValidNumber(tag: Int, variable: inout Double, errorMessage: String, dict: inout [Int: String])->Bool{
        if let x = Double(dict[tag]!) {
            variable = x
            return true
        }
        else {
            let alert = UIAlertController(title: "Input Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    /**
        Creates an alert given a title and error message.
     
     - parameter title: The title of the alert box.
     - parameter errorMessage: The message of the alert box.
     
     # Usage Example: #
     ````
     createAlert("Invalid", "Invalid input")
     ````
    */
    private func createAlert(title: String, errorMessage: String){
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: SkyView Gesture recognizer
    /**
        Decrease the Sun Temperature based on movement.
    */
    @IBAction func handleSkyGesture(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self.view)
        let unitPerMovement:CGFloat = 1/5.0
        
        //Get the movement difference in degrees
        var temp = unitPerMovement * translation.x
        var atmosTemp = unitPerMovement * translation.y
        //The temperature is subtracting from the sun intensity
        atmosTemp = atmosTemp * -1
        //Add the difference to our last temp value
        temp += Tair
        atmosTemp += Aair

        //round to tenths
        temp = round(num: temp, format: ".1")
        if(temp < -25){
            temp = -25
        }
        else if(temp > 10){
            temp = 10
        }
        tempLabel.text = String("Mean Air Temp = " + String(describing: temp) + " °C")
        tempLabel.sizeToFit()
        
        atmosTemp = round(num: atmosTemp, format: ".1")
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
        Tair = temp
        Aair = atmosTemp
        drawPermafrost()
    }
    
    //MARK: Line Gesture Recognizer
    /**
    To recognize a pan gesture (dragging) on a view (our lines in the UI)
 */
    @IBAction func handleGesture(recognizer:UIPanGestureRecognizer){
        //get the translation movement from the recognizer
        let translation = recognizer.translation(in: self.view)
        
        //move the view
        if let view = recognizer.view{
            
            //The new yVal of the line
            let newLineYValue = view.frame.minY + translation.y

            //We are moving the ground layer
            if view == lineGround {
               drawOrganic(view: view, newY: newLineYValue)
            }
            //We are moving the snow layer
            else if view == snowLineView {
                drawSnow(view: view, newY: newLineYValue)
            }
            //update our ALT
            drawPermafrost()
        }
        //Don't have image keep moving, set translation to zero because we are done
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    //MARK: Navigation
    /**
        We are navigating to the table view, pass our location.
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        //if the next view is our location table view
        guard let locationTableViewController = segue.destination as? LocationTableViewController else {
            fatalError("Expected destination: \(segue.destination)")
        }
        
        //save our configuration in case nothing changes
        saveUILocation()
        
        //send the location created by the user using the UI in case the user wants to make a new one
        location.name = "Current"
        locationTableViewController.uiLocation = location
        
    }
    
    //MARK: Helper Functions
    /**
     Draws the snow view based on the new y value of the line view (user dragged it).
     
     - parameter view: A UIView that is a line in our app. The line is draggable by the user.
     - parameter newY: The new proposed y value of the line view in our superview. It is proposed because it has been updated yet, not until it is verified to be valid movement.
     
     # Usage Example: #
     ````
     //see handleGesture for more
     drawSnow(lineView, 400.0)
     ````
    */
    private func drawSnow(view: UIView, newY: CGFloat){
        var newLineYValue = newY
        //the view above/before this one (will get resized because snow grows up)
        let previousView = skyView

        let skyViewHeightBound: CGFloat = sunView.frame.maxY + tempLabel.frame.height + padding/2
        let heightBound: CGFloat = 0.0
        var newImageViewHeight = staticLineGround.frame.minY - (newLineYValue + view.frame.height)
        
        var previousViewHeight: CGFloat = (previousView?.frame.height)!
        
        _ = getMovement(previousViewMinY: skyView.frame.minY, previousViewHeight: skyView.frame.height, previousHeightBound: skyViewHeightBound, heightBound: heightBound, newLineYValue: &newLineYValue, viewHeight: view.frame.height, followingMinY: staticLineGround.frame.minY, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)
        
        view.frame.origin = CGPoint(x: snowLineView.frame.minX, //only move vertically, don't change x
            y: newLineYValue)
        snowImageView.frame = CGRect(origin: CGPoint(x: view.center.x - snowImageView.frame.width/2, y: newLineYValue + snowLineView.frame.height), size: CGSize(width: (snowImageView.frame.width),height: newImageViewHeight))
        skyView.frame = CGRect(origin: CGPoint(x: (skyView.frame.minX), y: (skyView.frame.minY)), size: CGSize(width: (skyView.frame.width), height: previousViewHeight))
        
        //Update label position
        snowLabel.frame = CGRect(origin: CGPoint(x: snowLabel.frame.minX, y: previousViewHeight - snowLabel.frame.height - padding/4), size: CGSize(width: snowLabel.frame.width, height: snowLabel.frame.height))
        
        //update the values
        Hs = Double(getUnits(topAverageValue: 1.0, maxValue: 5.0, maxHeight: maxSnowHeight, newHeight: newImageViewHeight, percentage: 0.66))
        Hs = Double(round(num: CGFloat(Hs), format: ".2"))
        
        if(Hs == 0.0){
            snowLabel.text = "No Snow"
            snowLabel.sizeToFit()
        }
        else{
            snowLabel.text = "Snow Height = " + String(describing: Hs) + " m"
            snowLabel.sizeToFit()
        }

        updateSnowLabel()
    }
    
    /**
     Draw the organic layer and the views around it based on the line the user dragged.
     
     - parameter view: The line the user panned.
     - parameter newY: The new y value of the line view.
     
     # Usage Example: #
     ````
     //see handleGesture for more
     drawOrganic(lineView, 400)
     ````
    */
    private func drawOrganic(view: UIView, newY: CGFloat){
        var newLineYValue = newY
        let previousView = organicLayer
        
        //have to take into account the line heights into the height bound, or else previous view will be smaller than planned
        let groundLayerHeightBound: CGFloat = maxGroundHeight - maxOrganicLayerHeight - view.frame.height - staticLineGround.frame.height
        
        var newImageViewHeight = screenHeight - (newLineYValue + view.frame.height)
        
        var previousViewHeight: CGFloat = (previousView?.frame.height)!
        
        _ = getMovement(previousViewMinY: organicLayer.frame.minY, previousViewHeight: organicLayer.frame.height, previousHeightBound: 0.0, heightBound: groundLayerHeightBound, newLineYValue: &newLineYValue, viewHeight: view.frame.height, followingMinY: screenHeight, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)
        
        view.frame = CGRect(origin: CGPoint(x: lineGround.frame.minX, //only move vertically, don't change x
            y: newLineYValue), size: CGSize(width: lineGround.frame.width, height: lineGround.frame.height))
        
        groundImageView.frame = CGRect(origin: CGPoint(x: view.center.x - groundImageView.frame.width/2, y: newLineYValue + lineGround.frame.height), size: CGSize(width: (groundImageView.frame.width),height: newImageViewHeight))
        organicLayer.frame = CGRect(origin: CGPoint(x: organicLayer.frame.minX, y: organicLayer.frame.minY), size: CGSize(width: (organicLayer.frame.width),height: previousViewHeight))
        
        //Re-draw label with new coordinates and values
        var num = getUnits(topAverageValue: 0, maxValue: groundMaxUnitHeight, maxHeight: maxOrganicLayerHeight, newHeight: previousViewHeight, percentage: 0.0)
        
        num = round(num: num, format: ".2")
        Hv = Double(num)
        updateOrganicLabel()
    }
    
    /**
        Updates the Atmospheric Temperature Label (the sun). Since there is a subscript, we have to use attributed strings, which is easier in a function.
     
     - parameter newText: The new temperature value of the Aair variable.
     
         # Example Usage #
        ````
        //If we are in a gesture function ...
        updateAairLabel()
        ````
    */
    private func updateAairLabel(newText: String){
        atmosphericTempLabel.text = "Air Temp Amplitude = " + newText + " °C"
        atmosphericTempLabel.sizeToFit()
    }
    
    /**
        Draws the permafrost image view and the permafrost label in the correct location on the device.
    */
    private func drawPermafrost(){

        //update the permafrost value so we know where to draw
        updatePermafrostLabel()

        //the maximum the permafrost line can go to not interfere with bottom labels
        let maxY = screenHeight - (padding * (3/4)) - (groundLabel.frame.height * 2) - permafrostImageView.frame.height
 
        //the minimum the permafrost line can go (ground)
        let minY = (screenHeight * (0.5)) + staticLineGround.frame.height + zeroInView
        
        //the permafrost line will line up with the organic layer thickness (up to 0.25 on screen)
        //then it will expand by 1m/screenUnit until max
        let maxHeight = maxY - minY

        //Can change for Stakeholder needs
        let maxVal:CGFloat = 2.0
        
        var height: CGFloat = 0
        //calculate where the line should be drawn
        if(ALT < groundMaxUnitHeight){
            height = ALT *  (maxOrganicLayerHeight) / (groundMaxUnitHeight)
        }
        else{
            height = ALT * (maxHeight - maxOrganicLayerHeight)/maxVal + (maxOrganicLayerHeight)
        }
        var yPos = height + minY //the actual y value on the screen
        if yPos < minY {
            yPos = minY
        }
        else if yPos > maxY {
            yPos = maxY
        }
        
        //find where the coordinates are
        let rect = CGRect(origin: CGPoint(x: 0, y: yPos), size: CGSize(width: UIScreen.main.bounds.width, height: permafrostImageView.frame.height))
        permafrostImageView.frame = rect

        //update the permafrost's label position to be under the image view
        updatePermafrostLabel()
    }
    
    /**
     Load the location value from the table view cell.
    */
    @IBAction func unwindToUI(sender: UIStoryboardSegue){
        loadUI()
    }
    
    /**
     Load the location values into our variables in our class.
    */
    private func loadUI(){
        //load the location values in
        Kvf = location.Kvf
        Kvt = location.Kvt
        Kmf = location.Kmf
        Kmt = location.Kmt
        Cmf = location.Cmf
        Cmt = location.Cmt
        Cvf = location.Cvf
        Cvt = location.Cvt
        Hs = location.Hs
        Hv = location.Hv
        Cs = location.Cs
        Tgs = location.Tgs
        eta = location.eta
        Ks = location.Ks
        Tair = CGFloat(location.Tair)
        Aair = CGFloat(location.Aair)
        ALT = CGFloat(location.ALT)
        
        //Update Temp labels
        tempLabel.text = String("Mean Air Temp = " + String(describing: Tair) + " °C")
        tempLabel.sizeToFit()
        updateAairLabel(newText: String(describing: Aair))
        
        //Update SkyView
        skyView.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: screenWidth, height: snowLineView.frame.minY))
        
        //Update Snow Layer
        //change the positions of the views to match
        var newHeight = getHeightFromUnits(unit: CGFloat(Hs), maxHeight: maxSnowHeight, maxValue: 5.0, percentage: 0.66, topAverageValue: 1.0)
        //draw views based on new heights
        redrawSnowBasedOnNewHeight(newHeight: newHeight)
        //update label
        updateSnowLabel()
        
        //draw organic layer's height
        newHeight = getHeightFromUnits(unit: CGFloat(Hv), maxHeight: maxOrganicLayerHeight, maxValue: groundMaxUnitHeight, percentage: 0.0, topAverageValue: 0.0)
        redrawOrganicBasedOnNewHeight(newHeight: newHeight)
        
        updateOrganicLabel()
        
        updateMineralLayer()
        
        //Update ALT and Tgs labels
        drawPermafrost()
    }
    
    /**
     Draw the snow image view given a new height.
     
     - parameter newHeight: The new height of the snow image view.
     
     # Usage Example: #
     ````
     //see loadUI() for more
     redrawSnowBasedOnNewHeight(400.0)
     ````
    */
    func redrawSnowBasedOnNewHeight(newHeight: CGFloat){
         snowImageView.frame = CGRect(origin: CGPoint(x: 0.0, y: staticLineGround.frame.minY - newHeight), size: CGSize(width: (snowImageView.frame.width), height: newHeight))
        snowLineView.frame.origin = CGPoint(x: 0.0, y: snowImageView.frame.minY - snowLineView.frame.height)
    }
    
    /**
        Redraw the organic image view based on height value.
     
     - parameter newHeight: The new height of the organic view.
     
     # Usage Example: #
     ````
     redrawOrganicBasedOnNewHeight(400.0)
     ````
    */
    private func redrawOrganicBasedOnNewHeight(newHeight: CGFloat){
        organicLayer.frame = CGRect(origin: CGPoint(x: 0.0, y: staticLineGround.frame.maxY), size: CGSize(width: (organicLayer.frame.width), height: newHeight))
        lineGround.frame.origin = CGPoint(x: 0.0, y: organicLayer.frame.maxY )
    }
    
    /**
     Redraw the mineral layer view based on the views around it.
    */
    private func updateMineralLayer(){
        let maxY = groundImageView.frame.maxY
        groundImageView.frame = CGRect(origin: CGPoint(x: 0.0, y: lineGround.frame.maxY), size: CGSize(width: (organicLayer.frame.width), height: maxY - staticLineGround.frame.maxY))
    }
    
    /**
     Update the snow label's text and position.
    */
    private func updateSnowLabel(){
        if(Hs == 0.0){
            snowLabel.text = "No Snow"
            snowLabel.sizeToFit()
        }
        else{
            snowLabel.text = "Snow Height = " + String(describing: Hs) + " m"
            snowLabel.sizeToFit()
        }
        
        //redraw the label to end in the same place on the screen
        let snowLabelNewX: CGFloat = organicLayer.frame.maxX - snowLabel.frame.width - padding/4
        snowLabel.frame = CGRect(origin: CGPoint(x: snowLabelNewX, y: snowLineView.frame.minY - padding/4 - snowLabel.frame.height), size: CGSize(width: snowLabel.frame.width, height: snowLabel.frame.height))
    }
    
    /**
     Update the organic label's text and position.
    */
    private func updateOrganicLabel(){
        if(Hv < 0.0001){
            Hv = 0.0
            groundLabel.text = "No Organic"
        }else{
            groundLabel.text = "Organic Layer Thickness = " + String(describing: Hv) + " m"
        }
        groundLabel.sizeToFit()
        
        let groundLabelNewX: CGFloat = organicLayer.frame.maxX - groundLabel.frame.width - padding/4
        let groundLabelNewY: CGFloat = padding/4
        groundLabel.frame = CGRect(origin: CGPoint(x: groundLabelNewX, y: groundLabelNewY), size: CGSize(width: groundLabel.frame.width, height: groundLabel.frame.height))
    }
    
    /**
        Load the UI values into the location object variable.
   */
    private func updateLocation(){
        location.Kvf =  Kvf
        location.Kvt = Kvt
        location.Kmf = Kmf
        location.Kmt = Kmt
        location.Cmf = Cmf
        location.Cmt = Cmt
        location.Cvf = Cvf
        location.Cvt = Cvt
        location.Hs = Hs
        location.Hv = Hv
        location.Cs = Cs
        location.Tgs = Tgs
        location.eta = eta
        location.Ks = Ks
        location.Tair = Double(Tair)
        location.Aair = Double(Aair)
        location.ALT = Double(ALT)
    }
    
    /**
        Save the location object to the device. (Is only saved to be loaded by the UI. Will not appear in the tableview.)
    */
    private func saveUILocation(){
        updateLocation()
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(location, toFile: Location.oneLocationURL.path)
        if isSuccessfulSave {
            os_log("Location successfully saved.", log: OSLog.default, type: .debug)
        }
        else{
            os_log("Failed to save locations...", log: OSLog.default, type: .error)
        }
    }
    
    /**
        Load a saved location object from the device to be manipulated again in the UI.
    */
    private func loadLocation()->[Location]?{
        return NSKeyedUnarchiver.unarchiveObject(withFile: Location.oneLocationURL.path) as? [Location]
    }

}


