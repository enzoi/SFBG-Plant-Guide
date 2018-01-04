//
//  Plant+CoreDataClass.swift
//  
//
//  Created by Yeontae Kim on 12/23/17.
//
//

import Foundation
import CoreData
import CoreLocation
import MapKit

@objc(Plant)
public class Plant: NSManagedObject {

    func getPinAnnotationsFromPin(plant: Plant) -> PinAnnotation {
        
        let pinAnnotation = PinAnnotation()
        pinAnnotation.setCoordinate(newCoordinate: CLLocationCoordinate2D(latitude: plant.latitude, longitude: plant.longitude))
        pinAnnotation.title = plant.scientificName
        pinAnnotation.subtitle = "Distance: N/A"
        
        return pinAnnotation
    }
    
}
