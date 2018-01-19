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

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [MKAnnotation]()
    var photoStore: PhotoStore!
    var locationManager: CLLocationManager?
    var fetchedPlants = [Plant]()
    var userCurrentLocation:CLLocation?

    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var loadingLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        
        let sfbgLocation = CLLocation(latitude: 37.767527, longitude: -122.469890)
        centerMapOnLocation(location: sfbgLocation)
        
        // Get photoStore from TabBarController
        let tabBar = self.tabBarController as! TabBarController
        self.photoStore = tabBar.photoStore
        self.locationManager = tabBar.locationManager
        
        locationManager?.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Check if there is an update then fetch again
        mapView.removeAnnotations(mapView.annotations)
        
        if fetchedPlants.count == 0 {
            fetchAllPlantMarkers()
        } else {
            self.mapView.addAnnotations(self.annotations)
        }
        
    }
    
    // Activity Indicator
    func showActivityIndicator(view: UIView) {
        container.frame = view.frame
        container.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2)
        container.backgroundColor = UIColor.whiteBackground
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2)
        loadingView.backgroundColor = UIColor.grayBackground
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: 30)
        
        loadingLabel = UILabel(frame: CGRect(x: 0, y: 55, width: 80, height: 15))
        loadingLabel.text = "Loading"
        loadingLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 15)!
        loadingLabel.textColor = UIColor.lightGray
        loadingLabel.textAlignment = .center
        
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)
        container.addSubview(loadingView)
        view.addSubview(container)
        activityIndicator.startAnimating()
        
        print(container, container.center, loadingView.center, activityIndicator)
    }
    
    func hideActivityIndicator(view: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    
    // Fetch all saved pins with annotation
    func fetchAllPlantMarkers() {
  
        mapView.delegate = self
        
        // Get all plants
        photoStore.fetchAllPlants() { (plantsResult) in
            
            switch plantsResult {
                
            case let .success(plants):

                let dispatchGroup = DispatchGroup()
                
                self.fetchedPlants = plants
                
                if self.fetchedPlants.count > 0 {
                    
                    self.showActivityIndicator(view: self.view)
                    
                    for plant in self.fetchedPlants {
                        
                        let pinAnnotation = plant.getPinAnnotationsFromPin(plant: plant)
                        
                        let photos = plant.photo?.allObjects as! [Photo]

                        for photo in photos {
                            
                            dispatchGroup.enter()
                            
                            self.photoStore.fetchImage(for: photo, completion: { (result) in
                                if case let .success(image) = result {
                                    dispatchGroup.leave()
                                }
                            })
                        }
                        
                        self.annotations.append(pinAnnotation)
                        
                    }
                    
                    performUIUpdatesOnMain {
                        self.mapView.addAnnotations(self.annotations)
                        dispatchGroup.notify(queue: .main) {
                            print("Finished all requests.")
                            self.hideActivityIndicator(view: self.view)
                        }
                    }
                    
                } else {
                    print("Nothing to fetch")
                }
                
            case .failure(_):
                self.fetchedPlants = []
            }
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

// MARK: - Map View Delegate

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
     
        let identifier = "pin"
        var view: MKAnnotationView
        
        if annotation is PinAnnotation {
            
            if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                
                pinView.annotation = annotation
                view = pinView
                
            } else {
                
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.image = #imageLiteral(resourceName: "icons8-oak-tree-100")
                
                let plant = fetchedPlants.filter{ $0.scientificName == annotation.title! }.first
                
                var frame = view.frame
                frame.size.height = 35
                frame.size.width = 35
                view.frame = frame
                
                let photos = plant?.photo?.allObjects as! [Photo]
                
                if let photo = photos.first {

                    let plantImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
                    plantImageView.layer.cornerRadius = 22.5
                    plantImageView.layer.masksToBounds = true
                    
                    photoStore.fetchImage(for: photo, completion: { (result) in
                        
                        if case let .success(image) = result {
                            
                            performUIUpdatesOnMain() {
                                plantImageView.image = image
                                view.leftCalloutAccessoryView = plantImageView
                            }
                        }
                    })
                }
            
                // Button to lead to detail view controller
                let arrowButton = UIButton(frame: CGRect.init(x: 200, y: 25, width: 25, height: 25))
                arrowButton.setImage(UIImage(named: "icons8-Forward Filled-50"), for: .normal)
                view.rightCalloutAccessoryView = arrowButton
                
            }

            return view
            
        } else {
            return nil
        }
    
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        if let index = fetchedPlants.index(where: { $0.scientificName == (view.annotation?.title)! }) {
            let selectedPlant = fetchedPlants[index]
            detailVC.plant = selectedPlant
            detailVC.photoStore = photoStore
        }
        
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
}


// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        let _ = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)

         locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .authorizedWhenInUse
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.01, 0.01))
        mapView.setRegion(coordinateRegion, animated: true)
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

