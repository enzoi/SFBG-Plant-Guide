//
//  User+CoreDataProperties.swift
//  
//
//  Created by Yeontae Kim on 11/29/17.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var uid: String?
    @NSManaged public var email: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var plant: NSSet?

}

// MARK: Generated accessors for plant
extension User {

    @objc(addPlantObject:)
    @NSManaged public func addToPlant(_ value: Plant)

    @objc(removePlantObject:)
    @NSManaged public func removeFromPlant(_ value: Plant)

    @objc(addPlant:)
    @NSManaged public func addToPlant(_ values: NSSet)

    @objc(removePlant:)
    @NSManaged public func removeFromPlant(_ values: NSSet)

}
