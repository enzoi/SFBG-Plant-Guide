//
//  MapViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 10/31/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
import UserNotificationsUI

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [MKAnnotation]()
    var photoStore: PhotoStore!
    var locationManager: CLLocationManager!
    var fetchedPlants = [Plant]()
    var userCurrentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        
        // Get photoStore from TabBarController
        let tabBar = self.tabBarController as! TabBarController
        self.photoStore = tabBar.photoStore
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        
        performUIUpdatesOnMain() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        let sfbgLocation = CLLocation(latitude: 37.767527, longitude: -122.469890)
        self.centerMapOnLocation(location: sfbgLocation)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.removeAnnotations(mapView.annotations)
        fetchAllPlantMarkers()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        if let index = self.fetchedPlants.index(where: { $0.scientificName == (view.annotation?.title)! }) {
            let selectedPlant = self.fetchedPlants[index]
            detailVC.plant = selectedPlant
            detailVC.photoStore = photoStore
        }
        
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    // Fetch all saved pins with annotation
    func fetchAllPlantMarkers() {
  
        mapView.delegate = self
        
        self.showActivityIndicator(view: self.view)
        
        // Try to fetch all plants from core data first
        self.photoStore.fetchAllPlants() { (plantsResult) in
            
            switch plantsResult {
                
            case let .success(plants):
                
                self.fetchedPlants = plants
                
                if self.fetchedPlants.count > 0 {
                    
                    print("fetched core data exist")
                    self.displayPins(plants: self.fetchedPlants)
                    
                } else {
                    
                    print("fetched core data doesn't exist so try to fetch using contentful api")
                    
                    self.photoStore.getDataFromContentful { (plantResult) in
                        
                        switch plantsResult {
                        
                        case let .success(plants):
                        
                            self.fetchedPlants = plants
                            print("fetch from contentful success", self.fetchedPlants)
                            
                            if self.fetchedPlants.count > 0 {
                                performUIUpdatesOnMain() {
                                    self.displayPins(plants: self.fetchedPlants)
                                }
                            }
                            
                            print("no fetched plants from contentful")
                        
                        case let .failure(error):
                            print(error)
                            self.fetchedPlants = []
                        }
                        
                    }
                }
                
                case let .failure(error):
                    print(error)
                    self.fetchedPlants = []
                }
            }
    }
    
    func displayPins(plants: [Plant]) {
        
        for plant in plants {
            
            let pinAnnotation = plant.getPinAnnotationsFromPin(plant: plant)
            
            let photos = plant.photo?.allObjects as! [Photo]
            
            if let photo = photos.first {
                
                self.photoStore.fetchImage(for: photo, completion: { (result) in
                    
                    switch result {
                    
                    case .success:
                        self.hideActivityIndicator(view: self.view)
                    
                    case let .failure(error):
                        self.showAlertWithError(title: "Error fetching data", error: PhotoError.imageCreationError)
                        print("Error fetching image for photo: \(error)")
                    }
                })
            }
            
            self.annotations.append(pinAnnotation)
            
        }
        
        performUIUpdatesOnMain {
            self.mapView.addAnnotations(self.annotations)
        }
    }
    


    @IBAction func segmentedControlAction(sender: UISegmentedControl!) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .satellite
        }
    }

}


// MARK: - Custom Pin Annotation

class PinAnnotation : NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var subtitle: String?
    
    init(plant: Plant) {
        self.coordinate = plant.coordinate
    }
    
}

