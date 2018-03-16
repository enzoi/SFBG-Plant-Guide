//
//  PlantTableViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit
import FirebaseAuth


class PlantTableViewController: UIViewController, CLLocationManagerDelegate {

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
    var locationManager: CLLocationManager?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Plant> = {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()

        let scientificNameSort = NSSortDescriptor(
            key: #keyPath(Plant.scientificName), ascending: true)
        fetchRequest.sortDescriptors = [scientificNameSort]
        
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
        photoStore = tabBar.photoStore
        locationManager = tabBar.locationManager
        locationManager?.delegate = self
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Plants"

        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All", "Tree", "Shrub", "Other"]
        searchController.searchBar.delegate = self
        
        if #available(iOS 11.0, *) {

            // Selected text
            let titleTextAttributesSelected = [NSAttributedStringKey.foregroundColor: UIColor.green]
            UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
            
            // Normal text
            let titleTextAttributesNormal = [NSAttributedStringKey.foregroundColor: UIColor.black]
            UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
            
            searchController.searchBar.searchBarStyle = UISearchBarStyle.default
            let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.backgroundColor = .white
            navigationItem.searchController = searchController

        } else {
            // Fallback on earlier versions
            navigationItem.titleView = searchController.searchBar
        }
        
        tableView.dataSource = self
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // Prepare for segue to detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? PlantTableViewCell,
           let selectedIndexPath = tableView.indexPath(for: cell) {
            
            let plant: Plant
            
            if self.searchPredicate == nil && self.scopePredicate == nil {
                plant = fetchedResultsController.object(at: selectedIndexPath)
            } else {
                plant = filteredPlants![selectedIndexPath.row]
            }
            
            let detailVC = segue.destination as! DetailViewController
            detailVC.photoStore = photoStore
            detailVC.plant = plant
        }
    }
    
}

// MARK: - UISearchBarDelegate

extension PlantTableViewController: UISearchBarDelegate {
    
    // The overall search bar related codes below refers to the solution from
    // https://www.raywenderlich.com/157864/uisearchcontroller-tutorial-getting-started
    
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
        cell.isFavorite = false
        configure(cell: cell, for: indexPath)
        return cell
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
        
        // Set up favorite status for current user
        guard let users = plant.users else { return }
        
        if users.count == 0 {
    
            cell.isFavorite = false
            cell.starButton.setImage(#imageLiteral(resourceName: "icons8-heart-outline-100"), for: .normal)
        
        } else {
            
            if let currentUser = Auth.auth().currentUser {

                if let _ = users.first(where: { ($0 as! User).uid == currentUser.uid }) {
                    
                    cell.isFavorite = true
                    cell.starButton.setImage(#imageLiteral(resourceName: "icons8-heart-outline-filled-100"), for: .normal)
                    
                } else {
                    
                    cell.isFavorite = false
                    cell.starButton.setImage(#imageLiteral(resourceName: "icons8-heart-outline-100"), for: .normal)
                }
                
            } else {
                
                cell.isFavorite = false
                cell.starButton.setImage(#imageLiteral(resourceName: "icons8-heart-outline-100"), for: .normal)
            }

        }
        
        // Get icon image for plant cell
        let photos = Array(plant.photo!) as! [Photo]
        
        if let photo = photos.first {
            
            photoStore.fetchFromPhoto(for: photo, completion: { (result) in
                
                if case let .success(image) = result {

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
        
        let plant: Plant
        
        if self.searchPredicate == nil && self.scopePredicate == nil {
            plant = fetchedResultsController.object(at: indexPathTapped)
        } else {
            plant = filteredPlants![indexPathTapped.row]
        }
   
        let moc = self.photoStore.managedContext
        let fetchRequest =  NSFetchRequest<NSManagedObject>(entityName: "User")
        let predicate = NSPredicate(format: "uid == %@", currentUser.uid)
        fetchRequest.predicate = predicate

        
        moc.performAndWait {
            
            guard let users = try? moc.fetch(fetchRequest) else { return }
            
            if cell.isFavorite == false {
                
                if users.first != nil {
                    let user = users.first as! User
                    user.uid = currentUser.uid
                    plant.addToUsers(user)
                    user.addToFavoritePlants(plant)
                } else {
                    let user = User(context: moc)
                    user.uid = currentUser.uid
                    plant.addToUsers(user)
                    user.addToFavoritePlants(plant)
                }

                self.startMonitoring(coordinate: plant.coordinate, identifier: plant.scientificName!)
                
                cell.isFavorite = true
                cell.starButton.setImage(#imageLiteral(resourceName: "icons8-heart-outline-filled-100"), for: .normal)
                
            } else {
                
                if let user = users.first {
                    plant.removeFromUsers(user as! User)
                    (user as! User).removeFromFavoritePlants(plant)
                }
                
                self.stopMonitoring(coordinate: plant.coordinate, identifier: plant.scientificName!)
                
                cell.isFavorite = false
                cell.starButton.setImage(#imageLiteral(resourceName: "icons8-heart-outline-100"), for: .normal)

            }
        }

    }

    // The geofencing related codes below refers to the solution from
    // https://www.raywenderlich.com/136165/core-location-geofencing-tutorial
    // and https://useyourloaf.com/blog/local-notifications-with-ios-10/
    
    func region(withCoordinate coordinate: CLLocationCoordinate2D, identifier: String) -> CLCircularRegion {
        
        let radius = 10
        let coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = CLCircularRegion(center: coordinate, radius: CLLocationDistance(radius), identifier: identifier)
        
        region.notifyOnEntry = true
        return region
    }
    
    func startMonitoring(coordinate: CLLocationCoordinate2D, identifier: String) {
        
        print("startMonitoring called")
        
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlertWithMessage(title:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            let region = self.region(withCoordinate: coordinate, identifier: identifier)
            locationManager?.startMonitoring(for: region)
            
            print("location manager start monitoring")
        
        } else {
        
            print("location manager not authorized")
            
            let alertController = UIAlertController (title: "Allow location service", message: "Your plant is saved!! Would you like the app to give you a notification as you approach favorite plants. Press 'Setting' to update the appsetting.", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }

    }
    
    func stopMonitoring(coordinate: CLLocationCoordinate2D, identifier: String) {
        
        print("location manager stop monitoring")
        guard let locationManager = locationManager else { return }
        
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
}

