//
//  FavoriteViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth

class FavoriteViewController: UIViewController {

    // MARK: - Properties
    fileprivate let plantCellIdentifier = "favoriteCell"
    var photoStore: PhotoStore!
    var favoritePlants: [Plant]?
    
    lazy var fetchedResultsController: NSFetchedResultsController<User> = {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.photoStore.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        // fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBarController as! TabBarController
        self.photoStore = tabBar.photoStore
        
        tableView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
              
        if let currenUser = Auth.auth().currentUser {
            let predicate = NSPredicate(format: "uid == %@", currenUser.uid)
            fetchedResultsController.fetchRequest.predicate = predicate
        
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
            }
            
            if let users = fetchedResultsController.fetchedObjects {
                if users.count > 0 {
                    let user = Array(users).first! as User
                    favoritePlants = Array(user.favoritePlants!) as? [Plant]
                } else {
                    favoritePlants = []
                }
            }

            tableView.reloadData()
            
        } else {
            favoritePlants = []
            tableView.reloadData()
            getAlertView(title: "No User Found", error: "You need to log in to save or view your favorite plants")
        }
    }
    
    // Prepare for segue to detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? FavoriteTableViewCell,
            let selectedIndexPath = tableView.indexPath(for: cell) {
            
            let detailVC = segue.destination as! DetailViewController
            guard let favoritePlants = favoritePlants else { return }
            
            let plant = favoritePlants[selectedIndexPath.row]
            detailVC.plant = plant
        }
    }
}

// MARK: - UITableViewDelegate

extension FavoriteViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailView", sender: indexPath)
    }
    
}

// MARK: - UITableViewDataSource

extension FavoriteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favoritePlants != nil {
            return favoritePlants!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteTableViewCell
        configure(cell: cell, for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
}


// MARK: - NSFetchedResultsControllerDelegate
/*
extension FavoriteViewController: NSFetchedResultsControllerDelegate {
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
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
*/

// MARK: - Internal
extension FavoriteViewController {
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        
        guard let cell = cell as? FavoriteTableViewCell else {
            return
        }
        
        let plant = favoritePlants?[indexPath.row]
        let photos = plant?.photo?.allObjects
        if let photo = photos?.first as? Photo, let imageData = photo.imageData {
            cell.scientificName.text = plant?.scientificName
            cell.commonName.text = plant?.commonName
            cell.plantImageView.image = UIImage(data: imageData as Data ,scale:1.0)
        }
        
    }
}

// MARK - FavoriteViewController (AlertController)

extension UIViewController {
    
    func getAlertView(title: String, error: String) {
        let alertController = UIAlertController(title: title, message: error, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}

