//
//  Plant+CoreDataProperties.swift
//  
//
//  Created by Yeontae Kim on 12/11/17.
//
//

import Foundation
import CoreData


extension Plant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plant> {
        return NSFetchRequest<Plant>(entityName: "Plant")
    }

    @NSManaged public var commonName: String?
    @NSManaged public var distance: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var scientificName: String?
    @NSManaged public var thumbnailPhoto: NSData?
    @NSManaged public var sunExposure: String?
    @NSManaged public var waterNeeds: String?
    @NSManaged public var climateZones: String?
    @NSManaged public var plantType: String?
    @NSManaged public var photo: NSSet?
    @NSManaged public var users: User?

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
