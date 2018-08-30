//
//  LocationTableViewCell.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 8/14/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit

/**
 A custom table view cell so we can add a load button in order to pass values from the cell to the first view controller (UI).
 */
class LocationTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var locationName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
