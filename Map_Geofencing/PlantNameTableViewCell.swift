//
//  PlantNameTableViewCell.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/9/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class PlantNameTableViewCell: UITableViewCell {

    @IBOutlet weak var scientificNameLabel: UILabel!
    @IBOutlet weak var commonNameLabel: UILabel!
    
    var item: PlantViewModelNamesItem? {
        didSet {
            guard let item = item else {
                return
            }
            scientificNameLabel?.text = item.scientificName
            commonNameLabel?.text = item.commonName
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        self.accessoryType = .disclosureIndicator

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        print("cell selected")
    }
    
}
