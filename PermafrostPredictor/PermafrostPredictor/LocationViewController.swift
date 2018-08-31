//
//  LocationViewController.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 8/2/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit
import os.log 

/**
    The location detail view. This is where the user can edit location values directly as well as save new locations to be added to the list.
 */
class LocationViewController: UIViewController {
    
    //MARK: Variables
    //items
    @IBOutlet weak var locationNameTextField: UITextField!
    
    //Temperature
    @IBOutlet weak var aairStepper: UIStepper!
    @IBOutlet weak var aairLabel: UILabel!
    @IBOutlet weak var tairLabel: UILabel!
    @IBOutlet weak var tempUIView: UIView!
    @IBOutlet weak var tairStepper: UIStepper!
    
    //Snow
    @IBOutlet weak var volumetricSnow: UITextField!
    @IBOutlet weak var thermalSnow: UITextField!
    @IBOutlet weak var snowHeightTextField: UITextField!
    @IBOutlet weak var snowUIView: UIView!
    
    //Organic
    @IBOutlet weak var organicThermalThawedTextField: UITextField!
    @IBOutlet weak var organicThermalFrozenTextField: UITextField!
    @IBOutlet weak var organicVolumetricThawedTextField: UITextField!
    @IBOutlet weak var organicVolumetricFrozenTextField: UITextField!
    @IBOutlet weak var organicThicknessTextField: UITextField!
    @IBOutlet weak var organicUIView: UIView!
    
    //Mineral
    @IBOutlet weak var mineralPorosityTextField: UITextField!
    @IBOutlet weak var mineralThermalThawedTextField: UITextField!
    @IBOutlet weak var mineralThermalFrozenTextField: UITextField!
    @IBOutlet weak var mineralVolumetricThawedTextField: UITextField!
    @IBOutlet weak var mineralVolumetricFrozenTextField: UITextField!
    @IBOutlet weak var mineralUIVIew: UIView!
    
    //location
    var location: Location?
    
    //inputs that are given from other view
    var ALT : Double = 0.0
    var Tgs: Double = 0.0
    
    //Buttons
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //Labels to add superscripts to (for units)
    @IBOutlet weak var snowVolHeatCapacityLabel: UILabel!
    @IBOutlet weak var organicVolHeatCapacityLabel: UILabel!
    @IBOutlet weak var mineralVolHeatCapacityLabel: UILabel!
    @IBOutlet weak var porosityLabel: UILabel!
    
    //MARK: Initialization
    /**
     View loaded, setup the steppers, titles, and background images.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //steppers
        //steppers wrap around to other value
        tairStepper.wraps = true
        aairStepper.wraps = true
        
        //if user holds down, the values will continue to change
        tairStepper.autorepeat = true
        aairStepper.autorepeat = true
        
        //stakeholder given values
        tairStepper.maximumValue = 10.0
        aairStepper.maximumValue = 25.0
        tairStepper.minimumValue = -25.0 
        aairStepper.minimumValue = 0.0
        
        //update labels to include units in superscript form
        let bigFont = UIFont(name: "Helvetica", size: 17)!
        let smFont = UIFont(name: "Helvetica", size: 14)!
        let heatCapacityUnits = superscriptTheString(str: "Volumetric Heat Capacity [MJ/m", toSuper: "3", strAtEnd: "/°C]", bigFont: bigFont, smallFont: smFont)
        snowVolHeatCapacityLabel.attributedText = heatCapacityUnits
        organicVolHeatCapacityLabel.attributedText = heatCapacityUnits
        mineralVolHeatCapacityLabel.attributedText = heatCapacityUnits

        let porosityLabel1 = superscriptTheString(str: "Porosity [m", toSuper: "3", strAtEnd: "/m", bigFont: bigFont, smallFont: smFont)
        let porosityLabelEnding = superscriptTheString(str: "", toSuper: "3", strAtEnd: "]", bigFont: bigFont, smallFont: smFont)
        porosityLabel1.append(porosityLabelEnding)
        porosityLabel.attributedText = porosityLabel1
        
        //View loaded, if we are editing an existing - load
        if let location = location {
            navigationItem.title = location.name
            locationNameTextField.text = location.name
            
            //Temperature
            aairLabel.text = String(describing: location.Aair)
            tairLabel.text = String(describing: location.Tair)
            tempUIView.backgroundColor = UIColor(patternImage: UIImage(named: "Sun")!)
            
            //Snow
            volumetricSnow.text = String(describing: location.Cs)
            thermalSnow.text = String(describing: location.Ks)
            snowHeightTextField.text = String(describing: location.Hs)
            snowUIView.backgroundColor = UIColor(patternImage: UIImage(named: "Snow")!)
            
            //Organic
            organicThermalThawedTextField.text = String(describing: location.Kvt)
            organicThermalFrozenTextField.text = String(describing: location.Kvf)
            organicVolumetricThawedTextField.text = String(describing: location.Cvt)
            organicVolumetricFrozenTextField.text = String(describing: location.Cvf)
            organicThicknessTextField.text = String(describing: location.Hv)
            organicUIView.backgroundColor = UIColor(patternImage: UIImage(named: "Ground")!)
            
            //Mineral
            mineralPorosityTextField.text = String(describing: location.eta)
            mineralThermalThawedTextField.text = String(describing: location.Kmt)
            mineralThermalFrozenTextField.text = String(describing: location.Kmf)
            mineralVolumetricThawedTextField.text = String(describing: location.Cmt)
            mineralVolumetricFrozenTextField.text = String(describing: location.Cmf)
            mineralUIVIew.backgroundColor = UIColor(patternImage: UIImage(named: "Empty")!)
        }
    }
    
    //MARK: Navigation
    /**
     If the save button was pressed, perform the segue.
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //call super's
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button wasn't pressed.", log: OSLog.default, type: .debug)
            return
        }
    }
    
    /**
        The cancel button was pressed, unwind to the previous view controller without changing anything.
    */
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        //depending on the presentation/segue type, we need to choose a dismissal type
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The LocationViewController is not inside a navigation controller.")
        }
    }
    
    /**
     A function to determine if the save should go through. We validate the user inputs before we perform the segue. If the inputs are within the correct bounds, we segue.
    */
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return validate()
    }
    
    //MARK: Public functions
    /**
     The Aair stepper changed values, update the Aair label.
    */
    @IBAction func aairStepperChanged(_ sender: UIStepper) {
        aairLabel.text = String(describing: sender.value)
    }
    
    /**
     The Tair stepper changed values, update the Tair label.
    */
    @IBAction func tairStepperChanged(_ sender: UIStepper) {
        tairLabel.text = String(describing: sender.value)
    }
    
    //MARK: Private functions
    /**
     An alert function that creates a popup. Used to alert the user that an input is invalid.
     
     - parameter title: The title of the alert.
     - parameter errorMessage: The message of the alert.
     
     # Usage Example: #
     ````
     createAlert("Error", "Input is invalid")
     ````
    */
    private func createAlert(title: String, errorMessage: String){
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
        To validate the inputs before they are saved
    */
    private func validate()->Bool{
        //validate the inputs
        let name = locationNameTextField.text ?? "untitled"
        
        //Temperature
        //Air Amplitude
        guard let aair = Double(aairLabel.text!) else {
            //alert
            createAlert(title: "Invalid Input", errorMessage: "Air Amplitude must be a positive number.")
            return false
        }
        //check if air amplitude is between 0 and 25
        if aair < 0 || aair > 25 {
            createAlert(title: "Invalid Aair Input", errorMessage: "Air Amplitude must be between 0 and 25.")
            return false
        }
        
        //Mean Annual Air Temperature
        guard let tair = Double(tairLabel.text!) else {
            createAlert(title: "Invalid Tair Input", errorMessage: "Mean Annual Temperature must be a number.")
            return false
        }
        
        //Snow inputs
        //Volumetric Heat Capacity
        guard let volSnow = Double(volumetricSnow.text!) else {
            createAlert(title: "Invalid Volumetric Heat Capacity of Snow", errorMessage: "Must be a number.")
            return false
        }
        //Thermal Conductivity
        guard let therSnow = Double(thermalSnow.text!) else {
            createAlert(title: "Invalid Thermal Conductivity of Snow", errorMessage: "Must be a number.")
            return false
        }
        guard let snowHeight = Double(snowHeightTextField.text!) else {
            createAlert(title: "Invalid Snow height", errorMessage: "Must be a number.")
            return false
        }
        if snowHeight < 0.0 || snowHeight > 5.0 {
            createAlert(title: "Invalid Snow Height", errorMessage: "Must be between 0 and 5 meters.")
            return false
        }
        
        //Organic inputs
        //Thermal Conductivity Thawed
        guard let organicThermThawed = Double(organicThermalThawedTextField.text!) else {
            createAlert(title: "Invalid Thawed Thermal Conductivity of Organic Layer", errorMessage: "Must be a number.")
            return false
        }
        //Thermal frozen
        guard let organicThermFrozen = Double(organicThermalFrozenTextField.text!) else {
            createAlert(title: "Invalid Frozen Thermal Conductivity of Organic Layer", errorMessage: "Must be a number.")
            return false
        }
        //Volumetric Heat Capacity Thawed
        guard let organicVolThawed = Double(organicVolumetricThawedTextField.text!) else {
            createAlert(title: "Invalid Thawed Volumetric Heat Capacity of Organic Layer", errorMessage: "Must be a number.")
            return false
        }
        //Volumetric Frozen
        guard let organicVolFrozen = Double(organicVolumetricFrozenTextField.text!) else {
            createAlert(title: "Invalid Frozen Volumetric Heat Capacity of Organic Layer", errorMessage: "Must be a number.")
            return false
        }
        //thickness
        guard let organicThickness = Double(organicThicknessTextField.text!) else {
            createAlert(title: "Invalid Organic Thickness", errorMessage: "Must be a number.")
            return false
        }
        if organicThickness < 0.0 || organicThickness > 0.25 {
            createAlert(title: "Invalid Organic Thickness", errorMessage: "Must be between 0 and 0.25 meters.")
            return false
        }
        
        //Mineral Layer
        //Porosity
        guard let mineralPorosity = Double(mineralPorosityTextField.text!) else {
            createAlert(title: "Invalid Porosity of Mineral Layer", errorMessage: "Must be a number.")
            return false
        }
        //Thermal Conductivity Thawed
        guard let mineralThermThawed = Double(mineralThermalThawedTextField.text!) else {
            createAlert(title: "Invalid Thawed Thermal Conductivity of Mineral Layer", errorMessage: "Must be a number.")
            return false
        }
        //Thermal Frozen
        guard let mineralThermFrozen = Double(mineralThermalFrozenTextField.text!) else {
            createAlert(title: "Invalid Frozen Thermal Conductivity of Mineral Layer", errorMessage: "Must be a number.")
            return false
        }
        //Volumetric Heat Capacity
        guard let mineralVolThawed = Double(mineralVolumetricThawedTextField.text!) else {
            createAlert(title: "Invalid Thawed Volumetric Heat Capacity of Mineral Layer", errorMessage: "Must be a number.")
            return false
        }
        guard let mineralVolFrozen = Double(mineralVolumetricFrozenTextField.text!) else {
            createAlert(title: "Invalid Frozen Volumetric Heat Capacity of Mineral Layer", errorMessage: "Must be a number.")
            return false
        }
 
        location = Location(name: name, Kvf: organicThermThawed, Kvt: organicThermFrozen, Kmf: mineralThermFrozen, Kmt: mineralThermThawed, Cmf: mineralVolFrozen, Cmt: mineralVolThawed, Cvf: organicVolFrozen, Cvt: organicVolThawed, Hs: snowHeight, Hv: organicThickness, Cs: volSnow, Tgs: Tgs, eta: mineralPorosity, Ks: therSnow, Tair: tair, Aair: aair, ALT: ALT)
        
        return true
    }
}
