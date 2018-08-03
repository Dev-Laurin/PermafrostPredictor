//
//  LocationViewController.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 8/2/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit
import os.log 

class LocationViewController: UIViewController {
    
    //items
    @IBOutlet weak var locationNameTextField: UITextField!
    
    //Temperature
    @IBOutlet weak var aairStepper: UIStepper!
    @IBOutlet weak var aairLabel: UILabel!
    @IBOutlet weak var tairLabel: UILabel!
    
    //Snow
    @IBOutlet weak var volumetricSnow: UITextField!
    @IBOutlet weak var thermalSnow: UITextField!
    @IBOutlet weak var snowHeightTextField: UITextField!
    
    //Organic
    @IBOutlet weak var organicThermalThawedTextField: UITextField!
    @IBOutlet weak var organicThermalFrozenTextField: UITextField!
    @IBOutlet weak var organicVolumetricThawedTextField: UITextField!
    @IBOutlet weak var organicVolumetricFrozenTextField: UITextField!
    @IBOutlet weak var organicThicknessTextField: UITextField!
    
    //Mineral
    @IBOutlet weak var mineralPorosityTextField: UITextField!
    @IBOutlet weak var mineralThermalThawedTextField: UITextField!
    @IBOutlet weak var mineralThermalFrozenTextField: UITextField!
    @IBOutlet weak var mineralVolumetricThawedTextField: UITextField!
    @IBOutlet weak var mineralVolumetricFrozenTextField: UITextField!
    
    //location
    var location: Location?
    
    //Buttons
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button wasn't pressed.", log: OSLog.default, type: .debug)
            return
        }
        
        //validate the inputs
        let name = locationNameTextField.text ?? "untitled"
        //Temperature
        //Air Amplitude
        guard let aair = Double(aairLabel.text!) else {
            //alert
            createAlert(title: "Invalid Input", errorMessage: "Air Amplitude must be a positive number.")
            return
        }
        //check if air amplitude is between 0 and 25
        if aair < 0 || aair > 25 {
           createAlert(title: "Invalid Aair Input", errorMessage: "Air Amplitude must be between 0 and 25.")
            return
        }
        //Mean Annual Air Temperature
        guard let tair = Double(tairLabel.text!) else {
            createAlert(title: "Invalid Tair Input", errorMessage: "Mean Annual Temperature must be a number.")
            return
        }
        if tair > 10 || tair < -25 {
            createAlert(title: "Invalid Tair Input", errorMessage: "Mean Annual Temperature must be between -25 and 10.")
            return
        }
        
        //Snow inputs
        //Volumetric Heat Capacity
        guard let volSnow = Double(volumetricSnow.text!) else {
            createAlert(title: "Invalid Volumetric Heat Capacity of Snow", errorMessage: "Must be a number.")
            return
        }
        //Thermal Conductivity
        guard let therSnow = Double(thermalSnow.text!) else {
            createAlert(title: "Invalid Thermal Conductivity of Snow", errorMessage: "Must be a number.")
            return
        }
        guard let snowHeight = Double(snowHeightTextField.text!) else {
            createAlert(title: "Invalid Snow height", errorMessage: "Must be a number.")
            return
        }
        if snowHeight < 0.0 || snowHeight > 5.0 {
            createAlert(title: "Invalid Snow Height", errorMessage: "Must be between 0 and 5 meters.")
            return
        }
        
        //Organic inputs
        //Thermal Conductivity Thawed
        guard let organicThermThawed = Double(organicThermalThawedTextField.text!) else {
            createAlert(title: "Invalid Thawed Thermal Conductivity of Organic Layer", errorMessage: "Must be a number.")
            return
        }
        //Thermal frozen
        guard let organicThermFrozen = Double(organicThermalFrozenTextField.text!) else {
            createAlert(title: "Invalid Frozen Thermal Conductivity of Organic Layer", errorMessage: "Must be a number.")
            return
        }
        //Volumetric Heat Capacity Thawed
        guard let organicVolThawed = Double(organicVolumetricThawedTextField.text!) else {
            createAlert(title: "Invalid Thawed Volumetric Heat Capacity of Organic Layer", errorMessage: "Must be a number.")
            return
        }
        //Volumetric Frozen
        guard let organicVolFrozen = Double(organicVolumetricFrozenTextField.text!) else {
            createAlert(title: "Invalid Frozen Volumetric Heat Capacity of Organic Layer", errorMessage: "Must be a number.")
            return
        }
        //thickness
        guard let organicThickness = Double(organicThicknessTextField.text!) else {
            createAlert(title: "Invalid Organic Thickness", errorMessage: "Must be a number.")
            return
        }
        if organicThickness < 0.0 || organicThickness > 0.25 {
            createAlert(title: "Invalid Organic Thickness", errorMessage: "Must be between 0 and 0.25 meters.")
            return
        }
        
        //Mineral Layer
        //Porosity
        guard let mineralPorosity = Double(mineralPorosityTextField.text!) else {
            createAlert(title: "Invalid Porosity of Mineral Layer", errorMessage: "Must be a number.")
            return
        }
        //Thermal Conductivity Thawed
        guard let mineralThermThawed = Double(mineralThermalThawedTextField.text!) else {
            createAlert(title: "Invalid Thawed Thermal Conductivity of Mineral Layer", errorMessage: "Must be a number.")
            return
        }
        //Thermal Frozen
        guard let mineralThermFrozen = Double(mineralThermalFrozenTextField.text!) else {
            createAlert(title: "Invalid Frozen Thermal Conductivity of Mineral Layer", errorMessage: "Must be a number.")
            return
        }
        //Volumetric Heat Capacity
        guard let mineralVolThawed = Double(mineralVolumetricThawedTextField.text!) else {
            createAlert(title: "Invalid Thawed Volumetric Heat Capacity of Mineral Layer", errorMessage: "Must be a number.")
            return
        }
        guard let mineralVolFrozen = Double(mineralVolumetricFrozenTextField.text!) else {
            createAlert(title: "Invalid Frozen Volumetric Heat Capacity of Mineral Layer", errorMessage: "Must be a number.")
            return
        }
        
        location = Location(name: name, Kvf: organicThermThawed, Kvt: organicThermFrozen, Kmf: mineralThermFrozen, Kmt: mineralThermThawed, Cmf: mineralVolFrozen, Cmt: mineralVolThawed, Cvf: organicVolFrozen, Cvt: organicVolThawed, Hs: snowHeight, Hv: organicThickness, Cs: volSnow, Tgs: , eta: mineralPorosity, Ks: therSnow, Tair: tair, Aair: aair, ALT: <#T##Double#>)
        //call super's
        super.prepare(for: segue, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAlert(title: String, errorMessage: String){
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
