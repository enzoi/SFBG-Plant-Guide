//
//  PlantTableViewCell.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import FirebaseAuth

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
        
        // TODO: Fix this
        starButton.setImage(#imageLiteral(resourceName: "icons8-heart-outline-100"), for: .normal)
        starButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        starButton.addTarget(self, action: #selector(handleMarkAsFavorite), for: .touchUpInside)
        self.accessoryView = starButton
        
        update(with: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        update(with: nil)
    }
    
    func update(with image: UIImage?) {
        
        if let imageToDisplay = image {
            plantImageView.image = imageToDisplay
        } else {
            plantImageView.image = #imageLiteral(resourceName: "icons8-tree-filled-100")
        }
        
    }
    
    @objc private func handleMarkAsFavorite() {
        
        if Auth.auth().currentUser != nil {
            print("there is a logged-in user", Auth.auth().currentUser!)
            delegate?.toggleFavorite(cell: self)
            // setUpToggleFavorite()
        } else {
            print("there is no user")
            parentViewController?.getAlertView(title: "Oops!!", error: "Saving a favorite requires sign-in. Please sign-in or sign-up")
        }
    }
    
    func setUpToggleFavorite() {

    }

}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}
