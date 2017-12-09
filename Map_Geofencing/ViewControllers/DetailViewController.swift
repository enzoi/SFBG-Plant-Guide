//
//  DetailViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var plant: Plant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        // Get plant data from TableViewController
        // Populate table view with the data
        let photos = Array(plant.photo!) as! [Photo]
        if let imageData = photos[0].imageData {
            self.plantImageView.image = UIImage(data: imageData as Data)
        }
    }



}
