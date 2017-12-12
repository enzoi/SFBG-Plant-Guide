//
//  PlantPropertiesTableViewCell.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/9/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class PlantPropertiesTableViewCell: UITableViewCell {

    @IBOutlet weak var plantTypeLabel: UILabel!
    @IBOutlet weak var climateZonesLabel: UILabel!
    @IBOutlet weak var sunExposureLabel: UILabel!
    @IBOutlet weak var waterNeedsLabel: UILabel!
    
    var item: PlantViewModelPropertiesItem? {
        didSet {
            guard let item = item else {
                return
            }
           
            plantTypeLabel.text = item.plantType
            climateZonesLabel.text = item.climateZones
            sunExposureLabel.text = item.sunExposure
            waterNeedsLabel.text = item.waterNeeds
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
