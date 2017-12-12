//
//  User+CoreDataProperties.swift
//  
//
//  Created by Yeontae Kim on 12/11/17.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var favoritePlants: NSSet?

}

// MARK: Generated accessors for favoritePlants
extension User {

    @objc(addFavoritePlantsObject:)
    @NSManaged public func addToFavoritePlants(_ value: Plant)

    @objc(removeFavoritePlantsObject:)
    @NSManaged public func removeFromFavoritePlants(_ value: Plant)

    @objc(addFavoritePlants:)
    @NSManaged public func addToFavoritePlants(_ values: NSSet)

    @objc(removeFavoritePlants:)
    @NSManaged public func removeFromFavoritePlants(_ values: NSSet)

}
