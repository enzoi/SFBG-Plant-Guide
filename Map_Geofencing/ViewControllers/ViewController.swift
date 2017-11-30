//
//  ViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 10/31/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    var coreDataStack: CoreDataStack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let camera = GMSCameraPosition.camera(withLatitude: 37.7669, longitude: -122.4716, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        // Add style
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        view = mapView
        
        let icon = UIImage(named: "marker_small")!.withRenderingMode(.alwaysTemplate)
        let markerView = UIImageView(image: icon)
        
        let currentLocation = CLLocationCoordinate2DMake(37.7669, -122.4716)
        let marker = GMSMarker(position: currentLocation)
        marker.title = "SFBG"
        marker.iconView = markerView
        marker.map = mapView
    }

    func centerMapOnLocation(location: CLLocation) {

    }

}

