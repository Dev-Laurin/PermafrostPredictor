//
//  LocationTableViewController.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 7/30/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit
import os.log

/**
 A class to control our table view. Contains a list of location objects.
 */
class LocationTableViewController: UITableViewController {

    //MARK: Variables
    var locations = [Location]()
    var uiLocation = Location()

    //MARK: Initialization
    /**
     The view loaded, initialize our list with previous saved ones, or defaults if there are none.
    */
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
    
    /**
     The default locations to be loaded into the array if the user hasn't stored any of their own.
    */
    private func loadDefaultLocations(){
        guard let location = Location(name: "Fairbanks", Kvf: 0, Kvt: 0, Kmf: 0, Kmt: 0, Cmf: 0, Cmt: 0, Cvf: 0, Cvt: 0, Hs: 0, Hv: 0, Cs: 0, Tgs: 0, eta: 0, Ks: 0, Tair: 0, Aair: 0, ALT: 0, Tvs: 0) else {
            fatalError("Failed to initialize default location.")
        }
        locations += [location]
        
    }

    // MARK: - Table view data source
    /**
     The number of sections in our table. We only have need of 1 big section.
    */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /**
     Return how many objects we have as our rows.
    */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    /**
     When cell is tapped, return that cell's location object.
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as? LocationTableViewCell else {
            fatalError("Cell is not of type LocationTableViewCell.")
        }
        let location = locations[indexPath.row]
        cell.locationName.text = location.name
        
        return cell
    }
    
    //MARK: Actions
    /**
     We have returned from the location detail view where we can edit a location and are adding/changing that location in the list.
    */
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
    
    /**
     Return true so that we can delete cells.
     */
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    /**
        Override to support editing the table view.
     */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            locations.remove(at: indexPath.row)
            saveLocations()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    // MARK: - Navigation
    /**
     Preparing for navigation to another view controller.
    */
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
                fatalError("Expected detail controller: \(String(describing: navController.topViewController))")
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
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            //get the index of the selected cell
            guard let indexPath = tableView.indexPath(for: cell) else {
                fatalError("The selected cell is not being displayed by the table.")
            }
            
            //pass the location to the next view
            let selectedLocation = locations[indexPath.row]
            locationDetailViewController.location = selectedLocation
        
        case "LoadUI":
            //downcast the destination view controller
            guard let viewController = segue.destination as? ViewController else {
                fatalError("Expected destination: \(segue.destination)")
            }
            //get the selected cell
            guard let button = sender as? UIButton else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let cell = button.superview?.superview as? LocationTableViewCell else {
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
            fatalError("Unexpected segue identifier: \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Private Methods
    /**
     Save the current list of locations to device for persistant data.
    */
    private func saveLocations(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(locations, toFile: Location.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Location successfully saved.", log: OSLog.default, type: .debug)
        }
        else{
            os_log("Failed to save locations...", log: OSLog.default, type: .error)
        }
    }
    
    /**
        Load location list from device.
    */ 
    private func loadLocations()->[Location]?{
        return NSKeyedUnarchiver.unarchiveObject(withFile: Location.ArchiveURL.path) as? [Location]
    }

}
