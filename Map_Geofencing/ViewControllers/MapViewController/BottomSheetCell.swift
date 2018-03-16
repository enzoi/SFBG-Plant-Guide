//
//  BottomSheetCell.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 3/15/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit

class BottomSheetCell: UITableViewCell {

    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var scientificName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
