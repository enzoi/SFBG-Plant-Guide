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

        // Accessory Button
        let wikiButton = UIButton(type: .custom)
        wikiButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        wikiButton.setImage(#imageLiteral(resourceName: "icons8-wikipedia-100"), for: .normal)
        wikiButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        self.accessoryView = wikiButton
        
    }

    @objc func buttonTapped(sender: UIButton) {
        print("button tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webVC = storyboard.instantiateViewController(withIdentifier :"webViewController") as! WebViewController
        let baseUrlString = "https://en.wikipedia.org/wiki/"
        
        guard let plantNameArray = self.commonNameLabel.text?.lowercased().components(separatedBy: " ") else { return }
        let searchURL = plantNameArray.joined(separator: "_")
        
        webVC.url = URL(string: baseUrlString + searchURL)
        
        let presentingVC = self.parentViewController as! DetailViewController
        presentingVC.navigationController?.pushViewController(webVC, animated: true)
    }
    
}
