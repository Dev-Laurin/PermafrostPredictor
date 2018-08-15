//
//  LocationTableViewCell.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 8/14/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var loadButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
