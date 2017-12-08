//
//  TableViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UIViewController {

    // MARK: - Properties
    fileprivate let plantCellIdentifier = "plantCell"
    var photoStore: PhotoStore!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Plant> = {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        
        let scientificNameSort = NSSortDescriptor(
            key: #keyPath(Plant.scientificName), ascending: true)
        fetchRequest.sortDescriptors = [scientificNameSort]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.photoStore.managedContext,
            sectionNameKeyPath: nil,
            cacheName: "SFBG")
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
    }
}

// MARK: - UITableViewDataSource

extension TableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath) as! TableViewCell
 
        configure(cell: cell, for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
}


// MARK: - NSFetchedResultsControllerDelegate
extension TableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! TableViewCell
            configure(cell: cell, for: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default: break
        }
    }
}

// MARK: - Internal
extension TableViewController {
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        
        guard let cell = cell as? TableViewCell else {
            return
        }
        
        let plant = fetchedResultsController.object(at: indexPath)
        
        // Getting photos from plant
        let photos = Array(plant.photo!) as! [Photo]
        print("photos: ", photos)
        
        if let photo = photos.first {
            
            print("photo: ", photo)
            
            photoStore.fetchImage(for: photo, completion: { (result) -> Void in
                
                if case let .success(image) = result {
                    
                    DispatchQueue.main.async {
                        cell.plantImageView.image = image
                        cell.scientificName.text = plant.scientificName
                        cell.commonName.text = plant.commonName
                    }
                    
                } else {
                    print("something wrong")
                }
            })
        }
        
        let starButton = UIButton(type: .system)
        starButton.setImage(#imageLiteral(resourceName: "icons8-star-40"), for: .normal)
        starButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        starButton.tintColor = .red
        starButton.addTarget(self, action: #selector(handleMarkAsFavorite), for: .touchUpInside)
        cell.accessoryView = starButton

    }
    
    @objc private func handleMarkAsFavorite() {
        print("favorite button pressed")
    }
}

