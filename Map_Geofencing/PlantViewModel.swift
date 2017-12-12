//
//  PlantViewModel.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/10/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation
import UIKit

enum PlantViewModelItemType {
    case photos
    case names
    case properties
}

protocol PlantViewModelItem {
    var type: PlantViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
    var isCollapsible: Bool { get }
    var isCollapsed: Bool { get set }
}

class PlantViewModel: NSObject {
    
    var items = [PlantViewModelItem]()
    
    init(plant: Plant) {
        super.init()
        
        print("plant in view model: ", plant)
        
        if let scientificName = plant.scientificName, let commonName = plant.commonName {
            let namesItem = PlantViewModelNamesItem(scientificName: scientificName, commonName: commonName)
            items.append(namesItem)
        }
        
        if let plantType = plant.plantType,
            let climateZones = plant.climateZones,
            let sunExposure = plant.sunExposure,
            let waterNeeds = plant.waterNeeds
        {
            let propertiesItem = PlantViewModelPropertiesItem(plantType: plantType, climateZones: climateZones, sunExposure: sunExposure, waterNeeds: waterNeeds)
            items.append(propertiesItem)
        }
        
        if let photos = plant.photo {
            let photoArray = Array(photos)
            if !photoArray.isEmpty {
                let photosItem = PlantViewModelPhotosItem(photos: photoArray as! [Photo])
                items.append(photosItem)
            }
        }
        
        for item in items {
           print("item: ", item)
        }
        
    }
}

extension PlantViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = self.items[section]
        if item.isCollapsible && item.isCollapsed {
            return 0
        }
        return item.rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item.type {
        case .photos:
            if let item = item as? PlantViewModelPhotosItem, let cell = tableView.dequeueReusableCell(withIdentifier: PlantPhotosTableViewCell.identifier, for: indexPath) as? PlantPhotosTableViewCell {
                
                // Page control
                let photo = item.photos[indexPath.row]
                cell.item = item
                
                return cell
            }
        case .names:
            if let cell = tableView.dequeueReusableCell(withIdentifier: PlantNameTableViewCell.identifier, for: indexPath) as? PlantNameTableViewCell {
                cell.item = item as! PlantViewModelNamesItem

                return cell
            }
        case .properties:
            if let cell = tableView.dequeueReusableCell(withIdentifier: PlantPropertiesTableViewCell.identifier, for: indexPath) as? PlantPropertiesTableViewCell {
                cell.item = item as! PlantViewModelPropertiesItem

                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as? HeaderView {
            headerView.item = self.items[section]
            headerView.section = section
            headerView.delegate = self as! HeaderViewDelegate // don't forget this line!!!
            return headerView
        }
        return UIView()
    }
}

 extension PlantViewModel: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("click cell")
    }

}


extension PlantViewModelItem {
    var rowCount: Int {
        return 1
    }
    
    var isCollapsible: Bool {
        return true
    }
}

// MARK: Plant View Model Items

class PlantViewModelPhotosItem: PlantViewModelItem {
    var type: PlantViewModelItemType {
        return .photos
    }
    
    var sectionTitle: String {
        return "Photos"
    }
    
    var rowCount: Int {
        return photos.count
    }
    
    var isCollapsed = true
    
    var photos: [Photo]
    
    init(photos: [Photo]) {
        self.photos = photos
    }
}

class PlantViewModelNamesItem: PlantViewModelItem {
    var type: PlantViewModelItemType {
        return .names
    }
    
    var sectionTitle: String {
        return "Plant Names"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var isCollapsed = true
    
    var scientificName: String
    var commonName: String
    
    init(scientificName: String, commonName: String) {
        self.scientificName = scientificName
        self.commonName = commonName
    }
}

class PlantViewModelPropertiesItem: PlantViewModelItem {
    var type: PlantViewModelItemType {
        return .properties
    }
    
    var sectionTitle: String {
        return "Plant Properties"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var isCollapsed = true
    
    var plantType: String
    var climateZones: String
    var sunExposure: String
    var waterNeeds: String
    
    init(plantType: String, climateZones: String, sunExposure: String, waterNeeds: String) {
        self.plantType = plantType
        self.climateZones = climateZones
        self.sunExposure = sunExposure
        self.waterNeeds = waterNeeds
    }
}

