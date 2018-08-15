//
//  LocationTableViewController.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 7/30/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit
import os.log

class LocationTableViewController: UITableViewController {

    var locations = [Location]()
    var uiLocation = Location()
    
    func loadDefaultLocations(){
        guard let location = Location(name: "Fairbanks", Kvf: 0, Kvt: 0, Kmf: 0, Kmt: 0, Cmf: 0, Cmt: 0, Cvf: 0, Cvt: 0, Hs: 0, Hv: 0, Cs: 0, Tgs: 0, eta: 0, Ks: 0, Tair: 0, Aair: 0, ALT: 0) else {
            fatalError("Failed to initialize default location.")
        }
        locations += [location]

    }

    override func viewDidLoad() {
        super.viewDidLoad()
 
        //use the default edit button for table view (deleting)
        //the leftmost right bar button
        navigationItem.rightBarButtonItems![1] = editButtonItem
        
        //if there is saved data - load that, otherwise load the defaults
        if let savedLocations = loadLocations() {
            locations += savedLocations
        }
        else {
            //load default locations
            loadDefaultLocations()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as? LocationTableViewCell else {
            fatalError("Cell is not of type LocationTableViewCell.")
        }
        let location = locations[indexPath.row]

        cell.locationName.text = location.name
        
        return cell
    }
    
    //MARK: Actions
    @IBAction func unwindToLocationList(sender: UIStoryboardSegue){
        if let sender = sender.source as? LocationViewController, let location = sender.location {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                //update existing location
                locations[selectedIndexPath.row] = location
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else{
                //Add a new location
                let newIndexPath = IndexPath(row: locations.count, section: 0)
                locations.append(location)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            //save the locations
            saveLocations()
        }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            locations.remove(at: indexPath.row)
            saveLocations()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? ""){
        case "AddItem":
            os_log("Adding a new location.", log: OSLog.default, type: .debug)
            
            //downcast the destination view controller
            guard let navController = segue.destination as? UINavigationController else {
                fatalError("Expected destination: \(segue.destination)")
            }
            //the view controller after navigation should be the detail view
            guard let locationDetailViewController = navController.topViewController as? LocationViewController else{
                fatalError("Expected detail controller: \(navController.topViewController)")
            }
            //pass the current UI data
            locationDetailViewController.location = uiLocation
  
        case "ShowDetail":
            //downcast the destination view controller
            guard let locationDetailViewController = segue.destination as? LocationViewController else {
                fatalError("Expected destination: \(segue.destination)")
            }
            //get the selected cell
            guard let cell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            //get the index of the selected cell
            guard let indexPath = tableView.indexPath(for: cell) else {
                fatalError("The selected cell is not being displayed by the table.")
            }
            
            //pass the location to the next view
            let selectedLocation = locations[indexPath.row]
            locationDetailViewController.location = selectedLocation
        
        case "LoadUI":
            print("Loading UI")
            //downcast the destination view controller
            guard let viewController = segue.destination as? ViewController else {
                fatalError("Expected destination: \(segue.destination)")
            }
            //get the selected cell
            guard let button = sender as? UIButton else {
                fatalError("Unexpected sender: \(sender)")
            }
            guard let cell = button.superview?.superview as? LocationTableViewCell else {
                print(button.superview?.superview)
                fatalError("Could not get tableviewcell from button superview")
                
            }
            //get the index of the selected cell
            guard let indexPath = tableView.indexPath(for: cell) else {
                fatalError("The selected cell is not being displayed by the table.")
            }
            
            //pass the location to the next view
            let selectedLocation = locations[indexPath.row]
            viewController.location = selectedLocation
            
        default:
            fatalError("Unexpected segue identifier: \(segue.identifier)")
        }
    }
    //MARK: Private Methods
    private func saveLocations(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(locations, toFile: Location.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Location successfully saved.", log: OSLog.default, type: .debug)
        }
        else{
            os_log("Failed to save locations...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadLocations()->[Location]?{
        return NSKeyedUnarchiver.unarchiveObject(withFile: Location.ArchiveURL.path) as? [Location]
    }

}
