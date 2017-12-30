//
//  ProfileViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import FirebaseAuth

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
        
        if Auth.auth().currentUser != nil {
            signInButton.setTitle("LOG OUT", for: .normal)
        } else {
            signInButton.setTitle("SIGN IN", for: .normal)
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        if Auth.auth().currentUser != nil { // Log out
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                signInButton.setTitle("SIGN IN", for: .normal)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        } else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let navigationController = storyBoard.instantiateViewController(withIdentifier: "signInViewController") as! UINavigationController
            self.present(navigationController, animated: true, completion: nil)
        }
    }

    
    


}
