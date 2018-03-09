//
//  WebViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 1/15/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "More Info"
        self.tabBarController?.tabBar.isHidden = true
        
        guard let url = url else { return }
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }

}
