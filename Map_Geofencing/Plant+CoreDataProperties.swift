//
//  Plant+CoreDataProperties.swift
//  
//
//  Created by Yeontae Kim on 3/14/18.
//
//

import Foundation
import CoreData
import MapKit


extension Plant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plant> {
        return NSFetchRequest<Plant>(entityName: "Plant")
    }

    @NSManaged public var climateZones: String?
    @NSManaged public var commonName: String?
    @NSManaged public var distance: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var plantType: String?
    @NSManaged public var scientificName: String?
    @NSManaged public var sunExposure: String?
    @NSManaged public var thumbnailPhoto: NSData?
    @NSManaged public var waterNeeds: String?
    @NSManaged public var plantDescription: String?
    @NSManaged public var photo: NSSet?
    @NSManaged public var users: NSSet?

}

// MARK: Generated accessors for photo
extension Plant {

    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo)

    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo)

    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)

    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)

}

// MARK: Generated accessors for users
extension Plant {

    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: User)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: User)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)

}

extension Plant: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let lat = CLLocationDegrees(latitude)
        let lon = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
