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

        // Set button label
        print("Current User: ", Auth.auth().currentUser)
        
        if Auth.auth().currentUser != nil {
            signInButton.setTitle("LOG OUT", for: .normal)
        } else {
            signInButton.setTitle("SIGN IN", for: .normal)
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        print(signInButton.titleLabel?.text)
        
        if Auth.auth().currentUser != nil && signInButton.titleLabel?.text == "LOG OUT" {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            signInButton.setTitle("SIGN IN", for: .normal)
        }
        
        if signInButton.titleLabel?.text == "SIGN IN" {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let navigationController = storyBoard.instantiateViewController(withIdentifier: "signInViewController") as! UINavigationController
            self.present(navigationController, animated: true, completion: nil)
        }
    }

    
    


}
