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
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNextCondensed-DemiBold", size: 20)!, NSAttributedStringKey.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor.darkGreen
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().isTranslucent = false
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "AvenirNextCondensed-Regular", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)

        // Tab Bar
        UITabBar.appearance().barTintColor = UIColor.darkGreen
        UITabBar.appearance().tintColor = UIColor.lightGreen
        UITabBar.appearance().isTranslucent = false
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.lightGreen], for: .selected)
        
        // Segmented Control
        UISegmentedControl.appearance().tintColor = UIColor.lightGray
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.darkGreen], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.lightGray], for: .normal)
    }
}

extension UINavigationItem{
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
    }
    
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false // Use AutoLayout
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
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

// Stack Overflow: https://stackoverflow.com/questions/29137488/how-do-i-resize-the-uiimage-to-reduce-upload-image-size
extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

