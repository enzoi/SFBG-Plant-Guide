//
//  SignInViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/20/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import GoogleSignIn

class SignInViewController: UIViewController, LoginButtonDelegate, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        let facebookLoginButton = LoginButton(readPermissions: [ .publicProfile ])

        facebookLoginButton.center = view.center
        facebookLoginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        view.addSubview(facebookLoginButton)
        
        facebookLoginButton.delegate = self
        */
        
        // Button for signing up with email and password
        let signUpButton = UIButton(type: .system)
        signUpButton.backgroundColor = .green
        signUpButton.frame = CGRect(x: 16, y: 80, width: view.frame.width - 32, height: 40)
        signUpButton.setTitle("Sign up with Email", for: .normal)
        signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 5
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped(sender:)), for: .touchUpInside)
        view.addSubview(signUpButton)
        
        // Add custom fb login button
        let customFBButton = UIButton(type: .system)
        customFBButton.backgroundColor = .blue
        customFBButton.frame = CGRect(x: 16, y: 130, width: view.frame.width - 32, height: 40)
        customFBButton.setTitle("Continue with Facebook", for: .normal)
        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBButton.setTitleColor(.white, for: .normal)
        customFBButton.layer.cornerRadius = 5
        view.addSubview(customFBButton)
        
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
        // Add google sign in button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 180, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func signUpButtonTapped(sender: UIButton) {
        print("sign up button pressed")
    }
    
    func handleCustomFBLogin() {
        let loginManager = LoginManager()
        loginManager.logIn([.email, .publicProfile], viewController: self) { result in
            switch result {
            case .failed(let error):
                print("FACEBOOK LOGIN FAILED: \(error)")
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Successfully logged in!")
                print("ACCESS TOKEN \(accessToken)")
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Did log out of facebook")
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print("Succesesfully logged in", result)
        
        showEmailAddress()
    }
    
    func showEmailAddress() {
        let accessToken = AccessToken.current
        guard let accessTokenString = accessToken?.authenticationToken else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
    
        Auth.auth().signIn(with: credentials) { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user", error ?? "")
                return
            }
            print("Successfully logged in with our user", user ?? "")
        }
        
        // https://stackoverflow.com/questions/39683862/facebook-graph-request-using-swift3
        let params = ["fields" : "id, email, name"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params)
        graphRequest.start {
            (urlResponse, requestResult) in
            
            switch requestResult {
            case .failed(let error):
                print("error in graph request:", error)
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                }
            }
        }
    }
    
}
