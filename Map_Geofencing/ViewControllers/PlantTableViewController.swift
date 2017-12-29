//
//  PlantTableViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth

class PlantTableViewController: UIViewController {

    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPlants : [Plant]? = nil
    var searchPredicate: NSPredicate?
    var scopePredicate: NSPredicate?
    var compoundPredicate: NSCompoundPredicate?
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
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
            cacheName: "PlantList")
        
        // fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    // @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tabBar = self.tabBarController as! TabBarController
        self.photoStore = tabBar.photoStore
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Plants"
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All", "Tree", "Shrub", "Other"]
        searchController.searchBar.delegate = self
        
        tableView.dataSource = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
    }
    
    // Prepare for segue to detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? PlantTableViewCell,
           let selectedIndexPath = tableView.indexPath(for: cell) {
            
            let detailVC = segue.destination as! DetailViewController
            let plant = fetchedResultsController.object(at: selectedIndexPath)
            detailVC.plant = plant
        }
    }
    
    // Activity Indicator
    func showActivityIndicator(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}

// MARK: - UISearchBarDelegate

extension PlantTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {

        scopePredicate = (scope == "All") ? nil : NSPredicate(format: "plantType == %@", scope)
        
        if searchBarIsEmpty() {
            if scopePredicate == nil {
                self.fetchedResultsController.fetchRequest.predicate = nil
                filteredPlants = self.fetchedResultsController.fetchedObjects
            } else {
                filteredPlants = self.fetchedResultsController.fetchedObjects?.filter() {
                    return scopePredicate!.evaluate(with: $0)
                    } as [Plant]?
            }
            
        } else {
            searchPredicate = NSPredicate(format: "scientificName contains[c] %@", searchText)
            let predicate = scopePredicate == nil ? searchPredicate : NSCompoundPredicate(andPredicateWithSubpredicates: [scopePredicate!, searchPredicate!])
            
            filteredPlants = self.fetchedResultsController.fetchedObjects?.filter() {
                return (predicate?.evaluate(with: $0))!
                } as [Plant]?
            
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.fetchedResultsController.fetchRequest.predicate = nil
        filteredPlants = self.fetchedResultsController.fetchedObjects
        
        tableView.reloadData()
    }
    
}


// MARK: - UISearchResultsUpdating Delegate (informed when search bar became first responder)

extension PlantTableViewController: UISearchResultsUpdating {
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // called when text added or removed
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}


// MARK: - UITableViewDataSource

extension PlantTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.searchPredicate == nil && self.scopePredicate == nil {
            let sectionInfo = self.fetchedResultsController.sections![section] 
            return sectionInfo.numberOfObjects
        } else {
            return filteredPlants?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath) as! PlantTableViewCell
        
        cell.delegate = self
        configure(cell: cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
}

// MARK: - UITableViewDelegate

extension PlantTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetailView", sender: indexPath)
    }
}


// MARK: - Configure TableView Cell

extension PlantTableViewController {
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        
        guard let cell = cell as? PlantTableViewCell else {
            return
        }
        
        let plant: Plant
        
        if self.searchPredicate == nil && self.scopePredicate == nil {
            plant = fetchedResultsController.object(at: indexPath)
        } else {
            plant = filteredPlants![indexPath.row]
        }
        
        cell.scientificName.text = plant.scientificName
        cell.commonName.text = plant.commonName
        
        let photos = Array(plant.photo!) as! [Photo]
        
        guard let users = plant.users else { return }
        guard let currentUser = Auth.auth().currentUser else { return }
        
        for user in users {
            if (user as! User).uid == currentUser.uid {
                cell.isFavorite = true
                cell.starButton.setImage(#imageLiteral(resourceName: "icons8-star-filled-40"), for: .normal)
            } else {
                cell.isFavorite = false
                cell.starButton.setImage(#imageLiteral(resourceName: "icons8-star-40"), for: .normal)
            }
        }

        if let photo = photos.first {
        
            photoStore.fetchImage(for: photo, completion: { (result) in
                
                if case let .success(image) = result {
                    
                    self.hideActivityIndicator(uiView: self.view)
                    
                    performUIUpdatesOnMain() {
                        cell.plantImageView.image = image
                    }
                }
            })
        }
    }

}

// MARK: ToggleFavoriteDelgate

extension PlantTableViewController: ToggleFavoriteDelegate {
    
    func toggleFavorite(cell: PlantTableViewCell) {
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let plant = fetchedResultsController.object(at: indexPathTapped)
        let moc = self.photoStore.managedContext
        
        if plant.users?.count == 0 {

            if currentUser.uid != "" { // there is current user logged in

                let fetchRequest =  NSFetchRequest<NSManagedObject>(entityName: "User")
                
                // Fetch photos associalted with the specific pin
                let predicate = NSPredicate(format: "uid == %@", currentUser.uid)
                fetchRequest.predicate = predicate
                
                moc.perform {
                    
                    guard let users = try? moc.fetch(fetchRequest) else { return }
                    
                    if users.count == 0 { // no user in core data yet
                        // Create a user
                        let theUser = User(context: moc)
                        theUser.uid = currentUser.uid
                        theUser.addToFavoritePlants(plant)
                        
                    } else {
                        let theUser = users.first! as! User
                        theUser.addToFavoritePlants(plant)
                    }
                    
                    do {
                        try moc.save()
                    } catch {
                        moc.rollback()
                    }

                }

            } else {
                getAlertView(title: "Cannot add it to favorite plants", error: "Sign in required to save a plant to favorite. Please log in first")
            }
            
        } else { // Remove user from plant

            let fetchRequest =  NSFetchRequest<NSManagedObject>(entityName: "User")

            // Fetch photos associalted with the specific pin
            let predicate = NSPredicate(format: "uid == %@", currentUser.uid)
            fetchRequest.predicate = predicate
            
            moc.perform {
                
                if let users = try? moc.fetch(fetchRequest) {
                    let currentUser = users.first as! User
                    currentUser.removeFromFavoritePlants(plant)
                }
                
                do {
                    try moc.save()
                } catch {
                    moc.rollback()
                }
                
                // toggle favorite button
                cell.isFavorite = false
            }
        }
    }
    
}

