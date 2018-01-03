//
//  ProfileViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookCore
import FacebookLogin

class ProfileViewController: UIViewController {

    var photoStore: PhotoStore!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tabBar = self.tabBarController as! TabBarController
        self.photoStore = tabBar.photoStore
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let currentUser = Auth.auth().currentUser {
            
            // Set user image
            if let userImageURL = currentUser.photoURL {
                
                let session = URLSession(configuration: URLSessionConfiguration.default)
                let request = URLRequest(url: userImageURL)
                
                let task = session.dataTask(with: request) { (data, response, error) -> Void in
                    
                    let result = self.photoStore.processImageRequest(data: data, error: error)

                    if case let .success(image) = result {
                        
                        performUIUpdatesOnMain() {
                            self.profilePicture.image = image
                            self.profilePicture.layer.masksToBounds = true
                            self.profilePicture.layer.cornerRadius = 75
                        }
                    }
                }
                task.resume()
            } else {
                self.profilePicture.image = #imageLiteral(resourceName: "profile_default-100")
            }
            
            // Set user name
            if let userName = currentUser.displayName {
                self.profileName.text = userName
            } else if let email = currentUser.email {
                self.profileName.text = email
            } else {
                self.profileName.text = "user name"
            }
            
            signInButton.setTitle("LOG OUT", for: .normal)
            signInButton.setTitleColor(UIColor(red:1.0, green:0.0, blue:0.0, alpha:1.0), for: .normal)
            
        } else {
            
            self.profilePicture.image = #imageLiteral(resourceName: "profile_default-100")
            self.profilePicture.layer.cornerRadius = 75
            self.profilePicture.layer.masksToBounds = true
            signInButton.setTitle("SIGN IN", for: .normal)
            signInButton.setTitleColor(UIColor(red:0.0, green:1.0, blue:0.0, alpha:1.0), for: .normal)

        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {

        if Auth.auth().currentUser != nil && signInButton.titleLabel?.text == "LOG OUT" {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            self.profilePicture.image = #imageLiteral(resourceName: "profile_default-100")
            self.profilePicture.layer.cornerRadius = 75
            self.profilePicture.layer.masksToBounds = true
            signInButton.setTitle("SIGN IN", for: .normal)
            signInButton.setTitleColor(UIColor(red:0.0, green:1.0, blue:0.0, alpha:1.0), for: .normal)
        }
        
        if signInButton.titleLabel?.text == "SIGN IN" {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let navigationController = storyBoard.instantiateViewController(withIdentifier: "signInViewController") as! UINavigationController
            self.present(navigationController, animated: true, completion: nil)
        }
    }

    
    


}
