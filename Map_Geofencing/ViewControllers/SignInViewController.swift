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

class SignInViewController: UIViewController, LoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        GIDSignIn.sharedInstance().delegate = self
        
        // Button for signing in with email and password
        let label = UILabel()
        label.frame = CGRect(x: 45, y: 230, width: 200, height: 40)
        label.textAlignment = .right
        label.text = "Already have an account?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        view.addSubview(label)
        
        let signInButton = UIButton(type: .system)
        signInButton.frame = CGRect(x: 250, y: 230, width: 50, height: 40)
        signInButton.setTitle("Sign in", for: .normal)
        signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        signInButton.setTitleColor(.green, for: .normal)
        signInButton.addTarget(self, action: #selector(signInButtonTapped(sender:)), for: .touchUpInside)
        view.addSubview(signInButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func signUpButtonTapped(sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let signUpWithEmailViewController = storyBoard.instantiateViewController(withIdentifier: "signUpWithEmailViewController") as! SignUpWithEmailViewController
        self.navigationController?.pushViewController(signUpWithEmailViewController, animated: true)
    }
    
    func signInButtonTapped(sender: UIButton) {

        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
        let signInWithEmailViewController = storyBoard.instantiateViewController(withIdentifier: "signInWithEmailViewController") as! SignInWithEmailViewController
        self.navigationController?.pushViewController(signInWithEmailViewController, animated: true)
    }
    
    func handleCustomFBLogin() {
        let loginManager = LoginManager()
        loginManager.logIn([.email, .publicProfile], viewController: self) { result in
            switch result {
            case .failed(let error):
                print("FACEBOOK LOGIN FAILED: \(error)")
            case .cancelled:
                print("User cancelled login.")
            case .success(let accessToken):
                print("Successfully logged in!")
                print("ACCESS TOKEN \(accessToken)")
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("Failed to log into Google: ", error)
            return
        }
        
        print("Successfully logged into Google", user)
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Failed to create a Firebase User with Google account: ", error)
                return
            }
            
            guard let uid = user?.uid else { return }
            print("Successfully logged into Firebase with Google account", uid)
            
            self.dismiss(animated: true, completion: nil)
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
