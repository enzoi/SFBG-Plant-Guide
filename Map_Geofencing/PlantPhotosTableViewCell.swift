//
//  PlantPhotosTableViewCell.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/10/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class PlantPhotosTableViewCell: UITableViewCell {

    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    // Need to figure out page view controller for multiple photos
    var item: PlantViewModelPhotosItem? {
        didSet {
            guard let item = item else {
                return
            }
            
            print(item.photos)
            let photos = item.photos
                
            
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
