//
//  GCDBlackBox.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
