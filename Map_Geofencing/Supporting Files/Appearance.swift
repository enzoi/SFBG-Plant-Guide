//
//  Appearance.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 1/14/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit

struct Appearance {
    static func setGlobalAppearance() {
        
        // Status Bar
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Navigation Bar
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNextCondensed-DemiBold", size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor.darkGreen
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().isTranslucent = false
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AvenirNextCondensed-Regular", size: 18)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        
        // Tab Bar
        UITabBar.appearance().barTintColor = UIColor.darkGreen
        UITabBar.appearance().tintColor = UIColor.white
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
    }
}

extension UIColor {
    class var darkGreen: UIColor {
        return UIColor(red: 0.0 / 255.0, green: 143.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
    }
    
    class var lightGreen: UIColor {
        return UIColor(red: 188.0 / 255.0, green: 235.0 / 255.0, blue: 131.0 / 255.0, alpha: 1.0)
    }
    
    class var lighterGreen: UIColor {
        return UIColor(red: 188.0 / 255.0, green: 235.0 / 255.0, blue: 131.0 / 255.0, alpha: 0.2)
    }

}
