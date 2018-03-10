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
        
        let namesItem = PlantViewModelNamesItem(plant:plant)
        items.append(namesItem)
        
        if let plantType = plant.plantType,
            let climateZones = plant.climateZones,
            let sunExposure = plant.sunExposure,
            let waterNeeds = plant.waterNeeds
        {
            let propertiesItem = PlantViewModelPropertiesItem(plantType: plantType, climateZones: climateZones, sunExposure: sunExposure, waterNeeds: waterNeeds)
            items.append(propertiesItem)
        }

    }
}

extension PlantViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
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

        case .names:
            if let cell = tableView.dequeueReusableCell(withIdentifier: PlantNameTableViewCell.identifier, for: indexPath) as? PlantNameTableViewCell {
                cell.item = item as? PlantViewModelNamesItem

                return cell
            }
        case .properties:
            if let cell = tableView.dequeueReusableCell(withIdentifier: PlantPropertiesTableViewCell.identifier, for: indexPath) as? PlantPropertiesTableViewCell {
                cell.item = item as? PlantViewModelPropertiesItem
                
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
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension PlantViewModel: HeaderViewDelegate {
    
    func toggleSection(header: HeaderView, section: Int) {

        var item = items[section]
        
        if item.isCollapsible {
            
            // Toggle collapse
            let collapsed = !item.isCollapsed
            item.isCollapsed = collapsed
            header.setCollapsed(collapsed: collapsed)
            
            // Adjust the number of the rows inside the section
            
            self.reloadSections?(section)
        }
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
    
    var isCollapsed = false
    
    var plant: Plant
    
    init(plant: Plant) {
        self.plant = plant
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
    
    var isCollapsed = false
    
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

