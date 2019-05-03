//
//  ViewController.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 2/28/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit
import os

//Create a bigger hitbox for the moving the line views - but nothing else
//inspired by this answer: https://stackoverflow.com/questions/15553810/how-to-enlarge-hit-area-of-uigesturerecognizer 
extension UIImageView {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }
        
        //Only lineviews should have this tag
        if(self.tag == 111){
            let minHitArea = CGSize(width: 0, height: 50)
            let viewSize = self.bounds.size
            let heightToAdd = max(minHitArea.height - viewSize.height, 0)
            let largerFrame = self.bounds.insetBy(dx: 0, dy: -heightToAdd/2)
            return (largerFrame.contains(point)) ? self : nil
        }
        else{
            return self.frame.contains(point) ? self : nil 
        }
    }
}

/**
    Our one-page app. This is where everything happens, the view controller.
*/
class ViewController: UIViewController, UITextFieldDelegate {
    
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
    @IBOutlet weak var snowLineGestureAreaView: UIView!
    
    
    //Middle solid line that determines ground level of 0
    @IBOutlet weak var staticLineGround: UIImageView!
    
    //The roots/organic layer view and label
    @IBOutlet weak var organicLayer: UIView!
    @IBOutlet weak var groundLabel: UILabel!
    
    //Mineral layer
    @IBOutlet weak var lineGround: UIImageView!
    @IBOutlet weak var groundImageView: UIView!
    @IBOutlet weak var groundLineGestureAreaView: UIView!
    
    //Permafrost Layer
    private var permafrostLabel: UILabel
    private var permafrostImageView: UIImageView
    
    //Ground Temperature Label
    private var groundTempLabel: UILabel
    @IBOutlet weak var meanGroundSurfaceTemp: UILabel!
    
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
    private var Tvs: Double
    
    //Our location object so we can pass our values and load other locations from this UI easily
    var location: Location
    
    //where the view actually starts being drawn (taking out the navbar)
    private var zeroInView: CGFloat
    
    //Keep track of the info popup - is it visible or not?
    private var infoShowing: Bool
    private var sidebar: UIView
    
    //nav bar height
    private var barHeight: CGFloat

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
        location = Location(name: "Fairbanks", Kvf: 1.68, Kvt: 1.48, Kmf: 1.17, Kmt: 0.55, Cmf: 1.5, Cmt: 2.1, Cvf: 1.0, Cvt: 2.0, Hs: 0.40, Hv: 0.12, Cs: 0.84, Tgs: 0, eta: 0.5, Ks: 0.27, Tair: -2.3, Aair: 18.0, ALT: 0, Tvs: 0) ?? Location()

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
        Tvs = 0.0 //Mean Ground Surface Temperature
        
        //Wait until views are loaded to set real value
        zeroInView = 0
        
        //info popup box
        infoShowing = false
        
        //create a new view that is like a sidebar
        sidebar = UIView()
        
        //nav bar height
        barHeight = 44.0
        
        //Call the super version, recommended
        super.init(coder: coder )!
       //Call our function when the app goes into the background so we can save our configuration
        NotificationCenter.default.addObserver(self, selector: #selector(suspending), name: .UIApplication.didBecomeActiveNotification, object: nil)
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

        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "Sky")?.draw(in: self.view.bounds)

        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.view.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
        
        //Make the ground image repeat width wise, not height wise by setting the height to our
        //maximum view size
        //Changing Image Size solution from here: https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
        let img = UIImage(named: "Ground")
        let newSize = CGSize(width: organicLayer.frame.width, height: maxOrganicLayerHeight)
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: organicLayer.frame.width, height: maxOrganicLayerHeight))
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        img?.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Initialize Temperature Label (Mean Temperature)
        tempLabel.text = "Mean Air Temp: " + String(describing: Tair) + " °C"
        tempLabel.sizeToFit()
        tempLabel.backgroundColor = .white
        
        //Atmospheric Temperature
        updateAairLabel(newText: String(describing: Aair))
        atmosphericTempLabel.backgroundColor = .white 

        //Set the backgrounds of the views
        snowImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Snow")!)
        snowImageView.tag = 222
        
        organicLayer.backgroundColor = UIColor(patternImage: newImage!)
        groundImageView.backgroundColor = .gray //UIColor(patternImage: UIImage(named: "Empty")!)
        groundImageView.tag = 222

        //Initialize Labels
            //Have white "boxes" around the labels for better text readability

        snowLabel.backgroundColor = .white
        snowLabel.text = "Snow Height: " + String(describing: Hs) + " m"
        snowLabel.sizeToFit()
        
        groundLabel.text = "Organic Layer Thickness: " + String(describing: Hv) + " m"
        groundLabel.backgroundColor = .white
        groundLabel.sizeToFit()
        
        permafrostLabel.text = "Active Layer Thickness: " + String(describing: ALT) + " m"
        permafrostLabel.backgroundColor = .white
        permafrostLabel.sizeToFit()
        
        groundTempLabel.text = "Mean Annual Ground Temperature: " + String(describing: Tgs) + " °C"
        groundTempLabel.backgroundColor = .white
        groundTempLabel.sizeToFit()
        
        meanGroundSurfaceTemp.text = "Mean Ground Surface Temperature: " + String(describing: Tvs) + " °C"
        meanGroundSurfaceTemp.backgroundColor = .white
        meanGroundSurfaceTemp.sizeToFit()
        
        //update the permafrost view
        drawPermafrost()
        
        //The navigation bar size for some of the views for drawing
        //solution from: https://stackoverflow.com/questions/7312059/programmatically-get-height-of-navigation-bar
        if let navBarHeight: CGFloat = (UIApplication.shared.statusBarFrame.size.height +
            self.navigationController!.navigationBar.frame.height){
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
        snowLineGestureAreaView.backgroundColor = UIColor(white: 1, alpha: 0)
        groundLineGestureAreaView.backgroundColor = UIColor(white: 1, alpha: 0)
        
        let sunViewSize: CGFloat = skyView.frame.width/3
        
        sunView.frame = CGRect(origin: CGPoint(x:skyView.frame.width - sunViewSize, y: padding/2), size: CGSize(width: sunViewSize, height: sunViewSize))

        staticLineGround = changeViewsYValue(view: staticLineGround, newX: 0.0, newY: heightBasedOffPercentage) as? UIImageView

        snowImageView = changeViewsYValue(view: snowImageView, newX: 0.0, newY: staticLineGround.frame.minY - snowImageView.frame.height)
        
        snowLineView = changeViewsYValue(view: snowLineView, newX: 0.0, newY: snowImageView.frame.minY - snowLineView.frame.height) as? UIImageView
        snowLineView.tag = 111 //set as line view for hit bound increase
        
        organicLayer = changeViewsYValue(view: organicLayer, newX: 0.0, newY: staticLineGround.frame.maxY)
        
        lineGround = changeViewsYValue(view: lineGround, newX: 0.0, newY: organicLayer.frame.maxY) as? UIImageView
        lineGround.tag = 111

        //make overlapping uiview a gesture recognizer box fitting the snow line
        snowLineGestureAreaView.frame = CGRect(x: 0.0, y: snowLineView.frame.minY - (snowLineView.frame.height*3/2) + barHeight, width: screenWidth, height: snowLineView.frame.height*4)
        groundLineGestureAreaView.frame = CGRect(x: 0.0, y: lineGround.frame.minY - (lineGround.frame.height*3/2) + barHeight, width: screenWidth, height: lineGround.frame.height*4)

        groundImageView.frame = CGRect(origin: CGPoint(x: 0.0, y: lineGround.frame.maxY), size: CGSize(width: screenWidth, height: screenHeight - lineGround.frame.maxY))

        staticLineGround = changeViewsYValue(view: staticLineGround, newX: 0.0, newY: heightBasedOffPercentage) as? UIImageView
        
        //Make the Sun in its own view
        skyView.frame = CGRect(origin: CGPoint(x: 0.0, y:0.0), size: CGSize(width: screenWidth, height: screenHeight -  snowImageView.frame.minY - snowLineView.frame.height))
        
        //Make Info sidebar view
        sidebar.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: screenWidth/2, height: screenHeight))
        let gi_logo = UIImageView(image: UIImage(named: "GI_Logo"))
        let logoWidth = screenWidth/2 - padding/2
        gi_logo.frame = CGRect(origin: CGPoint(x: padding/4, y: screenHeight - padding/4 - logoWidth), size: CGSize(width: logoWidth, height: logoWidth))
        sidebar.addSubview(gi_logo)
        sidebar.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        
        let copyrightGIUAF = UITextView()
        copyrightGIUAF.backgroundColor = UIColor.clear
        copyrightGIUAF.frame = CGRect(origin: CGPoint(x: padding/4, y: zeroInView), size: CGSize(width: sidebar.frame.width - padding/2, height: sidebar.frame.height - zeroInView - (3*padding/4) - gi_logo.frame.height))
        let text = NSMutableAttributedString.init(string: "\n©2019 Geophysical Institute, University of Alaska Fairbanks. \n\nDesigned and conceived by Dmitry Nicolsky who is a part of the Snow, Ice, and Permafrost research group at the Geophysical Institute. We would like to thank the U.S. Permafrost Association for the additional support. Visit www.permafrostwatch.org \n\nDeveloped by Laurin McKenna.")
        copyrightGIUAF.attributedText = text
        //make hyperlink a different blue color for better matching of the background and underlined
        copyrightGIUAF.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1.0),  NSAttributedString.Key.underlineStyle.rawValue: NSUnderlineStyle.single.rawValue] as? [NSAttributedString.Key : Any]

        copyrightGIUAF.textColor = .white
        //Don't let user edit text - it's static
        copyrightGIUAF.isEditable = false
        //Automatically find links and open them in a browser 
        copyrightGIUAF.dataDetectorTypes = UIDataDetectorTypes.link
         copyrightGIUAF.frame = CGRect(origin: CGPoint(x: padding/4, y: zeroInView), size: CGSize(width: sidebar.frame.width - padding/2, height: sidebar.frame.height - zeroInView - (3*padding/4) - gi_logo.frame.height))

        let maxHeight = sidebar.frame.height - zeroInView - (3*padding/4) - gi_logo.frame.height
        let maxWidth = sidebar.frame.width - padding/2
        //Make the text fit any screen
        for i in 1...50 {
            copyrightGIUAF.font = copyrightGIUAF.font!.withSize(CGFloat(i))
            copyrightGIUAF.frame.size = CGSize(width: maxWidth, height: maxHeight)
            copyrightGIUAF.sizeToFit()
            
            if copyrightGIUAF.frame.height > maxHeight {
                copyrightGIUAF.font = copyrightGIUAF.font!.withSize(CGFloat(i - 1))
                break
            }
        }
        
        //set the size
        sidebar.frame.origin = CGPoint(x: -sidebar.frame.width, y: 0)
        sidebar.addSubview(copyrightGIUAF)

        view.addSubview(sidebar)
    }
    
    /**
     Draw the label locations initially
    */
    private func drawInitLabels(){
        var maxFonts = [CGFloat]()
        //Aair label
        atmosphericTempLabel.frame.origin = CGPoint(x: skyView.frame.minX + padding/2, y: sunView.frame.minY)
        maxFonts.append(findMaxFontForLabel(label: atmosphericTempLabel, maxSize: sunView.frame.minX - padding/2))

        //Tair
        tempLabel.frame.origin = CGPoint(x: skyView.frame.minX + padding/2, y: sunView.frame.minY + tempLabel.frame.height + padding/4)
        maxFonts.append(findMaxFontForLabel(label: tempLabel, maxSize: sunView.frame.minX - padding/2))
        
        //Tvs
        meanGroundSurfaceTemp.frame.origin = CGPoint(x:  groundImageView.frame.maxX - meanGroundSurfaceTemp.frame.width - padding/4, y: snowLineView.frame.minY - padding/4 - meanGroundSurfaceTemp.frame.height )
        maxFonts.append(findMaxFontForLabel(label: meanGroundSurfaceTemp, maxSize: screenWidth - padding/2))
        
        //Snow
        snowLabel.frame = CGRect(origin: CGPoint(x: skyView.frame.maxX - snowLabel.frame.width - padding/4, y: meanGroundSurfaceTemp.frame.minY - padding/4 - snowLabel.frame.height), size: CGSize(width: snowLabel.frame.width, height: snowLabel.frame.height))
        maxFonts.append(findMaxFontForLabel(label: snowLabel, maxSize: screenWidth - padding/2))
        
        //Organic
        groundLabel.frame.origin = CGPoint(x: organicLayer.frame.maxX - groundLabel.frame.width - padding/4, y: padding/4)
        maxFonts.append(findMaxFontForLabel(label: groundLabel, maxSize: screenWidth - padding/2))
        
        //ALT
        permafrostLabel.frame.origin = CGPoint(x:  groundImageView.frame.maxX - permafrostLabel.frame.width - padding/4 , y: self.view.frame.maxY - permafrostLabel.frame.height - padding/4)
        maxFonts.append(findMaxFontForLabel(label: permafrostLabel, maxSize: screenWidth - padding/2))
        
        //Tgs
        groundTempLabel.frame.origin = CGPoint(x:  groundImageView.frame.maxX - groundTempLabel.frame.width - padding/4, y: groundImageView.frame.maxY  - groundTempLabel.frame.height - padding/4 )
        maxFonts.append(findMaxFontForLabel(label: groundTempLabel, maxSize: screenWidth - padding/2))
        
        //Find which font size is the minimum that all the labels can do
        var minFont: CGFloat = maxFonts[0]
        for font in maxFonts {
            if font < minFont {
                minFont = font
            }
        }

        //Set all the labels to this new size
        atmosphericTempLabel.font = atmosphericTempLabel.font.withSize(minFont)
        atmosphericTempLabel.sizeToFit()
        tempLabel.font = tempLabel.font.withSize(minFont)
        tempLabel.sizeToFit()
        snowLabel.font = snowLabel.font.withSize(minFont)
        snowLabel.sizeToFit()
        groundLabel.font = groundLabel.font.withSize(minFont)
        groundLabel.sizeToFit()
        permafrostLabel.font = permafrostLabel.font.withSize(minFont)
        permafrostLabel.sizeToFit()
        meanGroundSurfaceTemp.font = meanGroundSurfaceTemp.font.withSize(minFont)
        meanGroundSurfaceTemp.sizeToFit()
        groundTempLabel.font = groundTempLabel.font.withSize(minFont)
        groundTempLabel.sizeToFit()
        
        //reset their origins
        atmosphericTempLabel.frame.origin = CGPoint(x: skyView.frame.minX + padding/2, y: sunView.frame.minY)

        //Tair
        tempLabel.frame.origin = CGPoint(x: skyView.frame.minX + padding/2, y: sunView.frame.minY + tempLabel.frame.height + padding/4)

        //Tvs
        meanGroundSurfaceTemp.frame = CGRect(origin: CGPoint(x: skyView.frame.maxX - meanGroundSurfaceTemp.frame.width - padding/4, y: snowLineView.frame.minY - padding/4 - meanGroundSurfaceTemp.frame.height  ), size: CGSize(width: meanGroundSurfaceTemp.frame.width, height: meanGroundSurfaceTemp.frame.height))

        //Snow
        snowLabel.frame = CGRect(origin: CGPoint(x: skyView.frame.maxX - snowLabel.frame.width - padding/4, y: meanGroundSurfaceTemp.frame.minY - snowLabel.frame.height - padding/4), size: CGSize(width: snowLabel.frame.width, height: snowLabel.frame.height))
 
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
        var minimumHeight = sunView.frame.minY + sunView.frame.height + snowLabel.frame.height + (padding/4)
        minimumHeight += padding/2
        //minimumHeight is the minimum Height we have to draw the top elements
        maxSnowHeight = heightBasedOffPercentage - minimumHeight
        
        maxGroundHeight = screenHeight - heightBasedOffPercentage //the minimum the grey view can be
    }
    
    /**
        Run the algorithm to find the permafrost depth and the ground temperature. Update the permafrost labels with the new values.
    */
    private func updatePermafrostLabel(){
        //update the value
        ALT = CGFloat(computePermafrost(Kvf: Kvf, Kvt: Kvt, Kmf: Kmf, Kmt: Kmt, Cmf: (Cmf * 1000000), Cmt: (Cmt * 1000000), Cvf: (Cvf * 1000000), Cvt: (Cvt * 1000000), Hs: Hs, Hv: Hv, Cs: (Cs * 1000000), magt: &Tgs, tTemp: Double(Tair), aTemp: Double(Aair), eta: eta, Ks: Ks, Tvs: &Tvs))
        
        //update the display
        ALT = round(num: ALT, format: ".2")
        permafrostLabel.text = "Active Layer Thickness: " + String(describing: ALT) + " m"
        permafrostLabel.sizeToFit()
        //update ground layer background color
        if(Tgs > 0){
            groundImageView.backgroundColor = UIColor(red: 205/255, green: 92/255, blue: 92/255, alpha: 1.0)
        }
        else{
            groundImageView.backgroundColor = UIColor(red: 100/255, green: 149/255, blue: 237/255, alpha: 1.0)
        }
        
        //update ground temperature label
        if(Tgs.isNaN){
            groundTempLabel.text = "Mean Annual Ground Temperature: " + "NaN" + " °C"
        }
        else {
            Tgs = Double(round(num: CGFloat(Tgs), format: ".2"))
            groundTempLabel.text = "Mean Annual Ground Temperature: " + String(describing: Tgs) + " °C"
        }
        groundTempLabel.sizeToFit()
        groundTempLabel.frame = CGRect(origin: CGPoint(x: groundImageView.frame.maxX - groundTempLabel.frame.width - padding/4, y: groundTempLabel.frame.minY), size: CGSize(width: groundTempLabel.frame.width, height: groundTempLabel.frame.height))
        
        if(Tvs.isNaN){
            meanGroundSurfaceTemp.text = "Mean Ground Surface Temperature: " + "NaN" + " °C"
        }
        else{
            Tvs = Double(round(num: CGFloat(Tvs), format: ".2"))
            meanGroundSurfaceTemp.text = "Mean Ground Surface Temperature: " + String(describing: Tvs) + " °C"
            meanGroundSurfaceTemp.sizeToFit()
            meanGroundSurfaceTemp.frame = CGRect(origin: CGPoint(x: groundImageView.frame.maxX - meanGroundSurfaceTemp.frame.width - padding/4, y: meanGroundSurfaceTemp.frame.minY), size: CGSize(width: meanGroundSurfaceTemp.frame.width, height: meanGroundSurfaceTemp.frame.height))
        }
        
        //Exception Air Amp < | Mean Air Temp |
        //Ground temperatures = Mean Air Temp
        if Aair < abs(Tair) {
            Tvs = Double(Tair)
            Tvs = Double(round(num: CGFloat(Tvs), format: ".2"))
            meanGroundSurfaceTemp.text = "Mean Ground Surface Temperature: " + String(describing: Tvs) + " °C"
            meanGroundSurfaceTemp.sizeToFit()
            meanGroundSurfaceTemp.frame = CGRect(origin: CGPoint(x: groundImageView.frame.maxX - meanGroundSurfaceTemp.frame.width - padding/4, y: meanGroundSurfaceTemp.frame.minY), size: CGSize(width: meanGroundSurfaceTemp.frame.width, height: meanGroundSurfaceTemp.frame.height))

            Tgs = Double(Tair)
            Tgs = Double(round(num: CGFloat(Tgs), format: ".2"))
            groundTempLabel.text = "Mean Annual Ground Temperature: " + String(describing: Tgs) + " °C"
            
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
     Animate the sidebar opening and closing. 
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
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight*(3/2))
        scrollView.tag = 1000
        
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
        //make view appear in the middle of the scrollview instead of at the bottom
        textBoxPopup.center = CGPoint(x: scrollView.bounds.size.width/2, y: scrollView.bounds.size.height/2)
        scrollView.addSubview(textBoxPopup)
        self.view.addSubview(scrollView)
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
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight*(3/2))
        scrollView.tag = 1000
        
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
        //make view appear in the middle of the scrollview instead of at the bottom
        textBoxPopup.center = CGPoint(x: scrollView.bounds.size.width/2, y: scrollView.bounds.size.height/2)
        scrollView.addSubview(textBoxPopup)
        self.view.addSubview(scrollView)
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
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight*(3/2))
        scrollView.tag = 1000
        
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
        //make view appear in the middle of the scrollview instead of at the bottom
        textBoxPopup.center = CGPoint(x: scrollView.bounds.size.width/2, y: scrollView.bounds.size.height/2)
        scrollView.addSubview(textBoxPopup)
        self.view.addSubview(scrollView)
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
            let alert = UIAlertController(title: "Input Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
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
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: SkyView Gesture recognizer
    /**
        Decrease the Sun Temperature based on movement.
    */
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

        //round to tenths
        temp = round(num: temp, format: ".1")
        if(temp < -25){
            temp = -25
        }
        else if(temp > 10){
            temp = 10
        }
        tempLabel.text = String("Mean Air Temperature: " + String(describing: temp) + " °C")
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
        if recognizer.state == UIGestureRecognizer.State.ended {
            Tair = temp
            Aair = atmosTemp
        }
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
            if view == groundLineGestureAreaView {
               drawOrganic(view: view, newY: newLineYValue, translation: translation.y)
            }
            //We are moving the snow layer
            else if view == snowLineGestureAreaView {
                drawSnow(view: view, newY: newLineYValue, translation: translation.y)
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
    private func drawSnow(view: UIView, newY: CGFloat, translation: CGFloat){
        
        //the view above/before this one (will get resized because snow grows up)
        let previousView = skyView
        let lineView = snowLineView
        var newLineYValue = lineView!.frame.minY + translation

        let skyViewHeightBound: CGFloat = sunView.frame.maxY + tempLabel.frame.height + padding/2
        let heightBound: CGFloat = 0.0
        var newImageViewHeight = staticLineGround.frame.minY - (newLineYValue + lineView!.frame.height)
        
        var previousViewHeight: CGFloat = (previousView?.frame.height)!
        
        _ = getMovement(previousViewMinY: skyView.frame.minY, previousViewHeight: skyView.frame.height, previousHeightBound: skyViewHeightBound, heightBound: heightBound, newLineYValue: &newLineYValue, viewHeight: lineView!.frame.height, followingMinY: staticLineGround.frame.minY, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)
        
        lineView!.frame.origin = CGPoint(x: snowLineView.frame.minX, //only move vertically, don't change x
            y: newLineYValue)
        view.frame.origin = CGPoint(x: snowLineView.frame.minX, //only move vertically, don't change x
                y: lineView!.frame.minY + barHeight - lineView!.frame.height)

        snowImageView.frame = CGRect(origin: CGPoint(x: lineView!.center.x - snowImageView.frame.width/2, y: newLineYValue + snowLineView.frame.height), size: CGSize(width: (snowImageView.frame.width),height: newImageViewHeight))
        skyView.frame = CGRect(origin: CGPoint(x: (skyView.frame.minX), y: (skyView.frame.minY)), size: CGSize(width: (skyView.frame.width), height: previousViewHeight))
        
        //Update label position
        meanGroundSurfaceTemp.frame.origin =  CGPoint(x: snowLabel.frame.minX, y: previousViewHeight - padding/4 - meanGroundSurfaceTemp.frame.height)
        
        snowLabel.frame = CGRect(origin: CGPoint(x: snowLabel.frame.minX, y: meanGroundSurfaceTemp.frame.minY - snowLabel.frame.height - padding/4 ), size: CGSize(width: snowLabel.frame.width, height: snowLabel.frame.height))
        
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
    private func drawOrganic(view: UIView, newY: CGFloat, translation: CGFloat){
        let previousView = organicLayer
        let lineView = lineGround
        var newLineYValue = translation + lineView!.frame.minY
        
        //have to take into account the line heights into the height bound, or else previous view will be smaller than planned
        let groundLayerHeightBound: CGFloat = maxGroundHeight - maxOrganicLayerHeight - lineView!.frame.height - staticLineGround.frame.height
        
        var newImageViewHeight = screenHeight - (newLineYValue + lineView!.frame.height)
        
        var previousViewHeight: CGFloat = (previousView?.frame.height)!
        
        _ = getMovement(previousViewMinY: organicLayer.frame.minY, previousViewHeight: organicLayer.frame.height, previousHeightBound: 0.0, heightBound: groundLayerHeightBound, newLineYValue: &newLineYValue, viewHeight: lineView!.frame.height, followingMinY: screenHeight, previousViewNewHeight: &previousViewHeight, newHeight: &newImageViewHeight)
        
        lineView!.frame = CGRect(origin: CGPoint(x: lineGround.frame.minX, //only move vertically, don't change x
            y: newLineYValue), size: CGSize(width: lineGround.frame.width, height: lineView!.frame.height))
        view.frame = CGRect(origin: CGPoint(x: lineGround.frame.minX, //only move vertically, don't change x
            y: lineView!.frame.minY + barHeight - lineView!.frame.height), size: CGSize(width: lineGround.frame.width, height: view.frame.height))
        
        groundImageView.frame = CGRect(origin: CGPoint(x: lineView!.center.x - groundImageView.frame.width/2, y: newLineYValue + lineGround.frame.height), size: CGSize(width: (groundImageView.frame.width),height: newImageViewHeight))
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
        atmosphericTempLabel.text = "Air Temperature Amplitude: " + newText + " °C"
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
        tempLabel.text = String("Mean Air Temperature: " + String(describing: Tair) + " °C")
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
        snowLineGestureAreaView.frame = CGRect(x: 0.0, y: snowLineView.frame.minY - (snowLineView.frame.height*3/2) + barHeight, width: screenWidth, height: snowLineView.frame.height*4)
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
        groundLineGestureAreaView.frame = CGRect(x: 0.0, y: lineGround.frame.minY - (lineGround.frame.height*3/2) + barHeight, width: screenWidth, height: lineGround.frame.height*4)
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
            snowLabel.text = "Snow Height: " + String(describing: Hs) + " m"
            snowLabel.sizeToFit()
        }
        
        //redraw the label to end in the same place on the screen
        let snowLabelNewX: CGFloat = organicLayer.frame.maxX - snowLabel.frame.width - padding/4
        snowLabel.frame = CGRect(origin: CGPoint(x: snowLabelNewX, y: meanGroundSurfaceTemp.frame.minY - padding/4 - snowLabel.frame.height), size: CGSize(width: snowLabel.frame.width, height: snowLabel.frame.height))
    }
    
    /**
     Update the organic label's text and position.
    */
    private func updateOrganicLabel(){
        if(Hv < 0.0001){
            Hv = 0.0
            groundLabel.text = "No Organic"
        }else{
            groundLabel.text = "Organic Layer Thickness: " + String(describing: Hv) + " m"
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
        location.Tvs = Tvs
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


