//
//  AppDelegate.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 10/31/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
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
        
        // Google Maps API Key
        GMSServices.provideAPIKey("AIzaSyAfqIROyy9bL5-LOkbZsu_ISJ5Z1qY6lFM")

        // Firebase Setup
        FirebaseApp.configure()
        
        // Google Auth Setup
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // Facebook Auth Setup
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Pass photoStore to TabBarController
        guard let tabBarController = window?.rootViewController as? TabBarController else {
            return true
        }
        
        // Provide core data with hard coded plants data
        importJSONSeedDataIfNeeded()
        
        // Requesting Authorization for User Interactions
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        // Request Authorization for User Location Access
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Move to AppDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
        tabBarController.photoStore = photoStore
        tabBarController.locationManager = locationManager
        
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

                /*
                let users = jsonDictionary["users"] as! [[String:Any]]
                
                for user in users {
                    let _user = User(context: self.photoStore.managedContext)
                    _user.email = user["email"] as! String
                    _user.addToFavoritePlants(plant)
                }
                 */
                
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

extension AppDelegate: UNUserNotificationCenterDelegate {

    // MARK: - Region monitoring event handler
    
    func handleEvent(forRegion region: CLRegion!, plant: Plant) {
        
        // Create notification contents
        let content = UNMutableNotificationContent()
        content.title = "Nearby Plant"
        content.subtitle = plant.scientificName!
        content.body = "Find your plant nearby"
        
        let openAction = UNNotificationAction(identifier:"open",
                                              title:"Open",options:[])
        
        let category = UNNotificationCategory(identifier: "actionCategory",
                                              actions: [openAction],
                                              intentIdentifiers: [], options: [])
        
        content.categoryIdentifier = "actionCategory"
        
        UNUserNotificationCenter.current().setNotificationCategories(
            [category])
        
        let photos = Array(plant.photo!) as! [Photo]
        guard let photo = photos.first else { return }
        
        if let attachment = UNNotificationAttachment.create(identifier: plant.scientificName!, imageData: photo.imageData! as Data, options: nil) {
            content.attachments = [attachment]
        }
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        
        let requestIdentifier = "plantNotification"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request) { (error) in
            
            if (error != nil){
                print(error?.localizedDescription)
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "open":
            
            // Open Detail View Controller
            guard let tabBarController = window?.rootViewController as? TabBarController else { return }
            
            if let favoriteVC = tabBarController.viewControllers?[2].navigationController?.viewControllers.first {
                
                let storyboard = UIStoryboard (name: "Main", bundle: nil)
                let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                
                favoriteVC.navigationController?.pushViewController(detailVC, animated: true)
            }
            
        default:
            break
        }
        completionHandler()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if notification.request.identifier == "plantNotification" {
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            
            photoStore.fetchAllPlants() { (plantsResult) in
                
                switch plantsResult {
                    
                case let .success(plants):
                    
                    // Get plant with specific user & get favorite plants
                    let plant = plants.filter { $0.scientificName! == region.identifier }.first!
                    self.handleEvent(forRegion: region, plant: plant)
                    
                case .failure(_):
                    print("No plants")
                }
            }
        }
    }
}
