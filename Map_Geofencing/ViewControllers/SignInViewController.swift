//
//  SignInViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/20/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import FacebookLogin

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        
        view.addSubview(loginButton)
    }


}
