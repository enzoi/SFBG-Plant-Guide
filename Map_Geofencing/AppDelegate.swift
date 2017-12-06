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
    lazy var  photoStore = PhotoStore(modelName: "SFBG")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyAhnYWiV0UWHVEeppPkE55RDJbV8vO2VGk")
        
        // importJSONSeedDataIfNeeded()
        
        guard let navController = window?.rootViewController as? UINavigationController,
            let viewController = navController.topViewController as? FavoriteViewController else {
                return true
        }
        
        viewController.photoStore = photoStore
        
        importJSONSeedDataIfNeeded()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        photoStore.saveContext()
    }
}

// MARK: - Helper methods to create core data from seed.json

extension AppDelegate {
    func importJSONSeedDataIfNeeded() {
        
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        let count = try? self.photoStore.managedContext.count(for: fetchRequest)
        
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

                let plant = Plant(context: self.photoStore.managedContext)
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
                    let image = Photo(context: self.photoStore.managedContext)
                    plant.addToPhoto(image)
                }
                print("plant: ", plant)

            }

            photoStore.saveContext()
            print("Imported \(jsonArray.count) plants")

        } catch let error as NSError {
            print("Error importing plants: \(error)")
        }
    }
}
