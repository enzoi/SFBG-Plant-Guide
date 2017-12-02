//
//  AppDelegate.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 10/31/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var  coreDataStack = CoreDataStack(modelName: "SFBG")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyAhnYWiV0UWHVEeppPkE55RDJbV8vO2VGk")
        
        // importJSONSeedDataIfNeeded()
        
        guard let navController = window?.rootViewController as? UINavigationController,
            let viewController = navController.topViewController as? TableViewController else {
                return true
        }
        
        viewController.coreDataStack = coreDataStack
        
        importJSONSeedDataIfNeeded()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
}

// MARK: - Helper methods to create core data from seed.json

extension AppDelegate {
    func importJSONSeedDataIfNeeded() {
        
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        let count = try? coreDataStack.managedContext.count(for: fetchRequest)
        
        print(fetchRequest)
        
        guard let plantCount = count,
            plantCount == 0 else {
                return
        }
        
        importJSONSeedData()
    }
    
    func importJSONSeedData() {

        let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
        let jsonData = try! Data(contentsOf: jsonURL)

        do {
            let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [String: AnyObject]
            
            for jsonDictionary in jsonArray["plants"] as! [[String: AnyObject]] {
                let scientificName = jsonDictionary["scientificName"] as! String
                let commonNames = jsonDictionary["commonName"] as! [String]
                let plantTypes = jsonDictionary["commonName"] as! [String]
                let plantType = plantTypes[0]
                let location = jsonDictionary["location"] as! [String:AnyObject]
                let coordinate = location["coordinate"] as! [String:AnyObject]
                let latitude = coordinate["latitude"] as! Double
                let longitude = coordinate["longitude"] as! Double
                // let sunExposure = jsonDictionary["sunExposure"] as! [[String:Any]]
                let photos = jsonDictionary["photos"] as! [[String:Any]]

                let plant = Plant(context: coreDataStack.managedContext)
                plant.scientificName = scientificName
                plant.commonName = commonNames[0]
                // plant.plantType = plantType
                // plant.plantSize = plantSize
                // plant.droughtTolerant = droughtTolerant
                // plant.waterNeeds = waterNeeds
                plant.latitude = latitude
                plant.longitude = longitude
                // plant.sunExposure = sunExposure

                for photo in photos {
                    let image = Photo(context: coreDataStack.managedContext)
                    plant.addToPhoto(image)
                }
                print("plant: ", plant)

            }

            coreDataStack.saveContext()
            print("Imported \(jsonArray.count) plants")

        } catch let error as NSError {
            print("Error importing plants: \(error)")
        }
    }
}
