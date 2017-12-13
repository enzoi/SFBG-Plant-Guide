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
        
        viewModel.reloadSections = { [weak self] (section: Int) in
            self?.tableView?.beginUpdates()
            self?.tableView?.reloadSections([section], with: .fade)
            self?.tableView?.endUpdates()
        }
        
        print("plant", plant)
        print("view model: ", viewModel.items[2].sectionTitle)
        
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.sectionHeaderHeight = 40
        tableView?.separatorStyle = .none
        tableView?.dataSource = viewModel
        tableView?.delegate = viewModel
        
        tableView?.register(PlantPhotosTableViewCell.nib, forCellReuseIdentifier: PlantPhotosTableViewCell.identifier)
        tableView?.register(PlantNameTableViewCell.nib, forCellReuseIdentifier: PlantNameTableViewCell.identifier)
        tableView?.register(PlantPropertiesTableViewCell.nib, forCellReuseIdentifier: PlantPropertiesTableViewCell.identifier)
        
        print(tableView)
    }
    
}
