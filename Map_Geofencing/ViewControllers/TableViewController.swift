//
//  TableViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {

    var plants: [String: String] = ["image": "sample", "scientificName": "Aesculus Californica", "commonName": "California Buckeye"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
    }

}

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath) as! TableViewCell
        cell.plantImageView?.image = UIImage(named: plants["image"]!)
        cell.scientificName.text = plants["scientificName"]
        cell.commonName.text = plants["commonName"]
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
}
