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
            let viewController = navController.topViewController as? ViewController else {
                return true
        }
        
        viewController.coreDataStack = coreDataStack
        
        return true
    }

}


