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
    var locationManager:CLLocationManager? = .none
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Firebase Setup
        FirebaseApp.configure()
        
        // Google Auth Setup
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // Facebook Auth Setup
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Provide core data with hard coded plants data
        importJSONSeedDataIfNeeded()
        
        // Request Authorization for User Location Access
        performUIUpdatesOnMain {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        }

        // Pass photoStore to TabBarController
        guard let tabBarController = window?.rootViewController as? TabBarController else {
            return true
        }
        
        tabBarController.photoStore = photoStore
        tabBarController.locationManager = locationManager
        
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

extension AppDelegate: UNUserNotificationCenterDelegate {

    // MARK: - Region monitoring event handler
    
    // The geofencing related codes below refers to the solution from
    // https://www.raywenderlich.com/136165/core-location-geofencing-tutorial
    
    //  The notification related codes below refers to the solution from
    // https://stackoverflow.com/questions/39103095/unnotificationattachment-with-uiimage-or-remote-url
    // and https://useyourloaf.com/blog/local-notifications-with-ios-10/
    
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
        
        // Deliver the notification in one seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        
        let requestIdentifier = "plantNotification"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request) { (error) in
            
            if (error != nil){
                print(error?.localizedDescription ?? "something wrong")
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("location manager didChangeAuth called")
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        
            // Requesting Authorization for User Interactions only when location service granted
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
        
    }
    
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
