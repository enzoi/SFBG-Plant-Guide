//
//  SignInViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/20/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import FacebookLogin
import GoogleSignIn

class SignInViewController: UIViewController, LoginButtonDelegate, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let facebookLoginButton = LoginButton(readPermissions: [ .publicProfile ])

        facebookLoginButton.center = view.center
        facebookLoginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        view.addSubview(facebookLoginButton)
        
        facebookLoginButton.delegate = self
        
        // Add google sign in button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 110, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Did log out of facebook")
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print(result)
    }
    
}
