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
    var locationManager: CLLocationManager!
    var fetchedPlants = [Plant]()
    var userCurrentLocation:CLLocation?

    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        
        let sfbgLocation = CLLocation(latitude: 37.7672, longitude: -122.4675)
        centerMapOnLocation(location: sfbgLocation)
        
        // Get photoStore from TabBarController
        let tabBar = self.tabBarController as! TabBarController
        self.photoStore = tabBar.photoStore
        self.locationManager = tabBar.locationManager
        
        locationManager.delegate = self
        
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
    
    // Fetch all saved pins with annotation
    func fetchAllPlantMarkers() {
  
        mapView.delegate = self
        showActivityIndicator(uiView: self.view)
        
        // Get all plants
        photoStore.fetchAllPlants() { (plantsResult) in
            
            switch plantsResult {
                
            case let .success(plants):

                self.fetchedPlants = plants
                
                if self.fetchedPlants.count > 0 {
                    
                    for plant in self.fetchedPlants {
                        
                        let pinAnnotation = plant.getPinAnnotationsFromPin(plant: plant)
                        
                        let photos = plant.photo?.allObjects as! [Photo]
                        
                        for photo in photos {
                            
                            self.photoStore.fetchImage(for: photo, completion: { (result) in
                                if case let .success(image) = result {

                                    self.hideActivityIndicator(uiView: self.view)
                                }
                            })
                        }
                        
                        self.annotations.append(pinAnnotation)
                        
                    }
                    
                    performUIUpdatesOnMain {
                        self.mapView.addAnnotations(self.annotations)
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
        var view: MKPinAnnotationView
        
        if annotation is PinAnnotation {
            
            if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                
                pinView.annotation = annotation
                view = pinView
                
            } else {
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                
                let plant = fetchedPlants.filter{ $0.scientificName == annotation.title! }.first
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
        }
        
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
}


// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        let _ = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)

         locationManager.stopUpdatingLocation()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.02, 0.02))
        mapView.setRegion(coordinateRegion, animated: true)
    }

}


// MARK: - Custom Pin Annotation

class PinAnnotation : NSObject, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var pinAnnotations = [PinAnnotation]()
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    var id: String?
    var title: String?
    var subtitle: String?

    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
    
}

