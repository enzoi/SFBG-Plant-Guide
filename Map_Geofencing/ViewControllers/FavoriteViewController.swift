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

enum UserError: Error {
    case noUserError
}

extension UserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noUserError:
            return NSLocalizedString("Saving favorite plants requires login. Please sign up in profile page", comment: "Favorite Error")
        }
    }
}

class FavoriteViewController: UIViewController {

    // MARK: - Properties
    fileprivate let plantCellIdentifier = "favoriteCell"
    var photoStore: PhotoStore!
    var favoritePlants = [Plant]()
    
    // TODO: make this simple fetch request not controller
    lazy var fetchedResultsController: NSFetchedResultsController<User> = {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.photoStore.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

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
              
        if let currentUser = Auth.auth().currentUser {
            let predicate = NSPredicate(format: "uid == %@", currentUser.uid)
            fetchedResultsController.fetchRequest.predicate = predicate
        
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                showAlertWithError(title: "Fetching error", error: error)
            }
            
            if let users = fetchedResultsController.fetchedObjects {
                
                if users.count > 0 {
                    
                    let user = Array(users).first! as User
                    favoritePlants = Array(user.favoritePlants!) as! [Plant]
                    
                } else {
                    favoritePlants = []
                }
            }

            tableView.reloadData()
            
        } else {
            favoritePlants = []
            tableView.reloadData()
            showAlertWithError(title: "No User Found", error: UserError.noUserError)
        }
    }
    
    // Prepare for segue to detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? FavoriteTableViewCell,
            let selectedIndexPath = tableView.indexPath(for: cell) {
            
            let detailVC = segue.destination as! DetailViewController
            
            let plant = favoritePlants[selectedIndexPath.row]
            detailVC.photoStore = photoStore
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
        return favoritePlants.count
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


// MARK: - Internal
extension FavoriteViewController {
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        
        guard let cell = cell as? FavoriteTableViewCell else {
            return
        }
        
        let plant = favoritePlants[indexPath.row]
        let photos = plant.photo?.allObjects
        
        if let photo = photos?.first as? Photo {
            
            photoStore.fetchImage(for: photo, completion: { (result) in
                
                if case let .success(image) = result {
                    
                    performUIUpdatesOnMain() {
                        cell.scientificName.text = plant.scientificName
                        cell.commonName.text = plant.commonName
                        cell.plantImageView.image = image
                    }
                }
            })

        } 
    }
}


