//
//  MapViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 10/31/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    var photoStore: PhotoStore!
    var fetchedPlants = [Plant]()
    var locationManager = CLLocationManager()
    lazy var mapView = GMSMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get photoStore from TabBarController
        let tabBar = self.tabBarController as! TabBarController
        self.photoStore = tabBar.photoStore
        
        // Google Maps setting
        let camera = GMSCameraPosition.camera(withLatitude: 37.7669, longitude: -122.4716, zoom: 15.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.view = mapView
        self.mapView.delegate = self
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.7669, longitude: -122.4716)
        marker.title = "Tree Name"
        marker.snippet = "common name"
        marker.map = mapView
        
        //Location Manager code to fetch current location
        setUpLocationManager()
        
        // Fetch all plant markers
        fetchAllPlantMarkers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.clear()
        fetchAllPlantMarkers()
    }
    
    func setUpLocationManager() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    // Fetch all saved pins with annotation
    
    func fetchAllPlantMarkers() {
        
        photoStore.fetchAllMarkers() { (plantsResult) in
            
            switch plantsResult {
                
            case let .success(plants):
                
                self.fetchedPlants = plants
                
                if self.fetchedPlants.count > 0 {

                    for plant in self.fetchedPlants {
                        
                        let plantMarker = GMSMarker()
                        plantMarker.position = CLLocationCoordinate2D(latitude: plant.latitude, longitude: plant.longitude)
                        plantMarker.title = plant.scientificName
                        // plantMarker.snippet = plant.commonName
                        plantMarker.map = self.mapView

                    }
                    
                } else {
                    print("Nothing to fetch")
                }
                
            case .failure(_):
                self.fetchedPlants = []
            }
        }
        
    }
}

// MARK: - CLLocation Manager Delegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        let _ = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
//        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
//                                              longitude: userLocation!.coordinate.longitude, zoom: 13.0)
//         mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

        mapView.isMyLocationEnabled = true
        self.view = mapView
        
        locationManager.stopUpdatingLocation()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
    }
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("didTapInfoWindowOf")
        // TODO: present detail view
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        if let index = fetchedPlants.index(where: { $0.scientificName == marker.title }) {
            let selectedPlant = fetchedPlants[index]
            detailVC.plant = selectedPlant
        }
        
        self.navigationController?.pushViewController(detailVC, animated: true)

    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 50))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        
        let scientificNameLabel = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 15))
        scientificNameLabel.text = marker.title
        scientificNameLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(scientificNameLabel)
        
        return view
    }
}
