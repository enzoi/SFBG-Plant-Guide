//
//  Photo+CoreDataProperties.swift
//  
//
//  Created by Yeontae Kim on 11/29/17.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var remoteURL: NSObject?
    @NSManaged public var imageData: NSData?
    @NSManaged public var photoID: String?
    @NSManaged public var plant: Plant?

}
