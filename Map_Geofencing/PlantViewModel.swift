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
    var reloadSections: ((_ section: Int) -> Void)?
    
    init(plant: Plant) {
        
        if let scientificName = plant.scientificName, let commonName = plant.commonName {
            let namesItem = PlantViewModelNamesItem(scientificName: scientificName, commonName: commonName)
            print(namesItem.commonName)
            items.append(namesItem)
        }
        
        if let plantType = plant.plantType,
            let climateZones = plant.climateZones,
            let sunExposure = plant.sunExposure,
            let waterNeeds = plant.waterNeeds
        {
            let propertiesItem = PlantViewModelPropertiesItem(plantType: plantType, climateZones: climateZones, sunExposure: sunExposure, waterNeeds: waterNeeds)
            print(propertiesItem.climateZones)
            items.append(propertiesItem)
        }
        
        if let photos = plant.photo {
            let photoArray = Array(photos)
            if !photoArray.isEmpty {
                let photosItem = PlantViewModelPhotosItem(photos: photoArray as! [Photo])
                items.append(photosItem)
            }
        }
        
    }
}

extension PlantViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("number of rows in section called")
        
        let item = items[section]

        guard item.isCollapsible else {
            return item.rowCount
        }
        
        if item.isCollapsed {
            return 0
        } else {
            return item.rowCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.section]
        
        switch item.type {
        case .photos:
            if let item = item as? PlantViewModelPhotosItem, let cell = tableView.dequeueReusableCell(withIdentifier: PlantPhotosTableViewCell.identifier, for: indexPath) as? PlantPhotosTableViewCell {
                
                // Page control
                let photo = item.photos[indexPath.row]
                cell.item = item
                
                print("photos cell: ", cell)
                return cell
            }
        case .names:
            if let cell = tableView.dequeueReusableCell(withIdentifier: PlantNameTableViewCell.identifier, for: indexPath) as? PlantNameTableViewCell {
                cell.item = item as? PlantViewModelNamesItem

                print("names cell: ", cell)
                return cell
            }
        case .properties:
            if let cell = tableView.dequeueReusableCell(withIdentifier: PlantPropertiesTableViewCell.identifier, for: indexPath) as? PlantPropertiesTableViewCell {
                cell.item = item as? PlantViewModelPropertiesItem

                print("properties cell: ", cell)
                return cell
            }
        }
        return UITableViewCell()
    }
    
}

extension PlantViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
  
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as? HeaderView {
        
            let item = items[section]
            
            headerView.item = item
            headerView.section = section
            headerView.delegate = self
            
            return headerView
        }
        
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell tapped")
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}


extension PlantViewModel: HeaderViewDelegate {
    
    func toggleSection(header: HeaderView, section: Int) {
        
        print("toggleSection called")
        
        var item = items[section]
        print("item: ", item)
        
        if item.isCollapsible {
            
            print("collapsible")
            print(item.isCollapsed)
            // Toggle collapse
            let collapsed = !item.isCollapsed
            item.isCollapsed = collapsed
            header.setCollapsed(collapsed: collapsed)
            
            // Adjust the number of the rows inside the section
            
            self.reloadSections?(section)
        }
        
        print("not collapsible")
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
        return "Plant Images"
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

