//
//  LocationTableViewCell.swift
//  PermafrostPredictor
//
//  Created by Laurin Fisher on 8/14/18.
//  Copyright © 2018 Geophysical Institute. All rights reserved.
//

import UIKit

//Using delegate to get indexPath of custom table cell when clicking button idea from here:
//https://stackoverflow.com/questions/29913066/how-to-access-the-content-of-a-custom-cell-in-swift-using-button-tag
protocol LocationTableViewCellDelegate {
    func cellButtonTapped(cell: LocationTableViewCell)
}
class LocationTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var locationName: UILabel!

    @IBAction func loadButtonPressed(_ sender: Any) {
        delegate?.cellButtonTapped(cell: self)
    }
    var delegate: LocationTableViewCellDelegate? 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
