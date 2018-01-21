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
        // UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.defaultBlue], for: .selected)
        
        // Segmented Control
        UISegmentedControl.appearance().tintColor = UIColor.darkGreen
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.darkGreen], for: .normal)
    }
}

extension UIColor {
    
    class var defaultBlue: UIColor {
        return UIColor(red: 0.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    
    class var whiteBackground: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.3)
    }
    
    class var grayBackground: UIColor {
        return UIColor(red: 68.0 / 255.0, green: 68.0 / 255.0, blue: 68.0 / 255.0, alpha: 0.7)
    }
    
    class var darkGreen: UIColor {
        return UIColor(red: 30.0 / 255.0, green: 67.0 / 255.0, blue: 26.0 / 255.0, alpha: 1.0)
    }
    
    class var darkGreen20: UIColor {
        return UIColor(red: 30.0 / 255.0, green: 67.0 / 255.0, blue: 26.0 / 255.0, alpha: 0.2)
    }

    class var lightGreen: UIColor {
        return UIColor(red: 188.0 / 255.0, green: 235.0 / 255.0, blue: 131.0 / 255.0, alpha: 1.0)
    }
    
    class var lighterGreen: UIColor {
        return UIColor(red: 225.0 / 255.0, green: 240.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0)
    }

}
