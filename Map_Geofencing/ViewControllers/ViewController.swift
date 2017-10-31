//
//  ViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 10/31/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set initial location in SF Botanical Garden
        let initialLocation = CLLocation(latitude: 37.7669, longitude: -122.4716)
        
        centerMapOnLocation(location: initialLocation)
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}

