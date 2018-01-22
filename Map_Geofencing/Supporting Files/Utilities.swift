//
//  Utilities.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 1/4/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension UIViewController {
    
    func showAlertWithError(title: String, error: String) {
        let alertController = UIAlertController(title: title, message: error, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithMessage(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

//  // The notification related codes below refers to the solution from
// https://stackoverflow.com/questions/39103095/unnotificationattachment-with-uiimage-or-remote-url

extension UNNotificationAttachment {
    
    static func create(identifier: String, imageData: Data, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)

            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}
