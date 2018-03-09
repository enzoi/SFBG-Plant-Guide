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

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [MKAnnotation]()
    var photoStore: PhotoStore!
    var locationManager: CLLocationManager!
    var fetchedPlants = [Plant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get photoStore from TabBarController
        let tabBar = self.tabBarController as! TabBarController
        self.photoStore = tabBar.photoStore
        
        // Location Manager Setup
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        let sfbgLocation = CLLocation(latitude: 37.767527, longitude: -122.469890)
        centerMapOnLocation(location: sfbgLocation)
        
        // Fetch plants
        photoStore.fetchAllPlants() { (plantsResult) in
            
            switch plantsResult {
                
            case let .success(plants):
                
                self.fetchedPlants = plants
                
            case let .failure(error):
                print(error)
                self.fetchedPlants = []
            }
        }
        
        if self.fetchedPlants.count == 0 {
            fetchAllPlantMarkers()
        } else {
            displayPins(plants: self.fetchedPlants)
        }
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

        self.photoStore.getDataFromContentful { (plantResult) in
                        
            switch plantResult {
            
            case let .success(plants):
            
                self.fetchedPlants = plants
                self.hideActivityIndicator(view: self.view)
      
                if self.fetchedPlants.count > 0 {
                    performUIUpdatesOnMain() {
                        self.displayPins(plants: self.fetchedPlants)
                    }
                }
            
            case let .failure(error):
                self.hideActivityIndicator(view: self.view)
                self.showAlertWithError(title: "Error fetching data", error: error.localizedDescription as! Error)
                self.fetchedPlants = []
            }
        }
    }
    
    func displayPins(plants: [Plant]) {
        
        for plant in plants {
            
            let pinAnnotation = plant.getPinAnnotationsFromPin(plant: plant)
            
            let photos = plant.photo?.allObjects as! [Photo]
            
            if let photo = photos.first {
                
                self.photoStore.fetchFromPhoto(for: photo, completion: { (result) in
                    
                    switch result {
                    
                    case .success:
                        self.hideActivityIndicator(view: self.view)
                    
                    case let .failure(error):
                        self.showAlertWithError(title: "Error fetching image for photo", error: error.localizedDescription as! Error)
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

