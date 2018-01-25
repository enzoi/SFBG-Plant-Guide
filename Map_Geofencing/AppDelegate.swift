//
//  AppDelegate.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 10/31/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import GoogleSignIn
import CoreData
import CoreLocation
import UserNotifications
import UserNotificationsUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var  photoStore = PhotoStore(modelName: "SFBG")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Firebase Setup
        FirebaseApp.configure()
        
        // Google Auth Setup
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // Facebook Auth Setup
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Provide core data with hard coded plants data
        importJSONSeedDataIfNeeded()

        // Pass photoStore to TabBarController
        guard let tabBarController = window?.rootViewController as? TabBarController else {
            return true
        }
        
        tabBarController.photoStore = photoStore
        
        // Setup styles - status bar, nav bar, item
        Appearance.setGlobalAppearance()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        
        GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        
        return handled
        
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
                let location = jsonDictionary["location"] as! [String:AnyObject]
                let plantType = jsonDictionary["plantType"] as! String
                let climateZones = jsonDictionary["climateZones"] as! String
                let sunExposure = jsonDictionary["sunExposure"] as! String
                let waterNeeds = jsonDictionary["waterNeeds"] as! String
                let coordinate = location["coordinate"] as! [String:AnyObject]
                let latitude = coordinate["latitude"] as! Double
                let longitude = coordinate["longitude"] as! Double
                let photos = jsonDictionary["photos"] as! [[String:Any]]

                let plant = Plant(context: self.photoStore.managedContext)

                plant.scientificName = scientificName
                plant.commonName = commonNames[0]
                plant.latitude = latitude
                plant.longitude = longitude
                plant.plantType = plantType
                plant.climateZones = climateZones
                plant.sunExposure = sunExposure
                plant.waterNeeds = waterNeeds
                
                for photo in photos {
                    let image = Photo(context: self.photoStore.managedContext)
                    image.remoteURL = NSURL(string: photo["remoteURL"] as! String)
                    image.photoID = UUID().uuidString // Add unique photoID
                    plant.addToPhoto(image)
                }

            }

            photoStore.saveContext()

        } catch let error as NSError {
            print("Error importing plants: \(error)")
        }
    }
    
}

