//
//  WebViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 1/15/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://en.wikipedia.org/wiki/Sequoia_sempervirens")
        let request = URLRequest(url: url!)
        
        webView.loadRequest(request)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
