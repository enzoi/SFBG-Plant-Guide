//
//  DetailViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?
    
    var plant: Plant!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = PlantViewModel(plant: plant)
        
        tableView?.dataSource = viewModel
  
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableViewAutomaticDimension
        
        tableView?.register(PlantPhotosTableViewCell.nib, forCellReuseIdentifier: PlantPhotosTableViewCell.identifier)
        tableView?.register(PlantNameTableViewCell.nib, forCellReuseIdentifier: PlantNameTableViewCell.identifier)
        tableView?.register(PlantPropertiesTableViewCell.nib, forCellReuseIdentifier: PlantPropertiesTableViewCell.identifier)

    }

}
