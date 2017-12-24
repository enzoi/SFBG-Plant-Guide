//
//  PlantTableViewCell.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

protocol ToggleFavoriteDelegate: class { // Define Protocol
    func toggleFavorite(cell: PlantTableViewCell)
}

class PlantTableViewCell: UITableViewCell {

    weak var delegate: ToggleFavoriteDelegate?
    let starButton = UIButton(type: .system)
    var isFavorite: Bool = false
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var scientificName: UILabel!
    @IBOutlet weak var commonName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        starButton.setImage(#imageLiteral(resourceName: "icons8-star-40"), for: .normal)
        starButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        starButton.addTarget(self, action: #selector(handleMarkAsFavorite), for: .touchUpInside)
        self.accessoryView = starButton
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func handleMarkAsFavorite() {
        print("favorite button pressed")
        delegate?.toggleFavorite(cell: self)
        setUpToggleFavorite()
    }
    
    func setUpToggleFavorite() {
        if isFavorite == false {
            starButton.setImage(#imageLiteral(resourceName: "icons8-star-filled-40"), for: .normal)
            isFavorite = true
        } else {
            starButton.setImage(#imageLiteral(resourceName: "icons8-star-40"), for: .normal)
            isFavorite = false
        }
    }

}
