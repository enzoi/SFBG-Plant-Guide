//
//  PhotoStore.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/5/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import CoreData

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

extension PhotoError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .imageCreationError:
            return NSLocalizedString("Faied fetching image", comment: "Photo error")
        }
    }
}

enum PlantsResult {
    case success([Plant])
    case failure(Error)
}

class PhotoStore {
    
    private let imageStore = ImageStore()
    
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    private lazy var storeContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    
    // MARK: Downloading Image
    
    func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                
                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        
        return .success(image)
    }
    
    // photoURL for photo instance --> download image using web service and return UIImage
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have a photoID.")
        }
        
        if let image = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        
        // Otherwise, get an image using URL
        guard let photoURL = photo.remoteURL else {
            preconditionFailure("Photo expected to have a remote URL.")
        }
        
        let request = URLRequest(url: photoURL as URL)
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            
            // After get the imageData, store the image in core data
            if case let .success(image) = result {
                 self.imageStore.setImage(image, forKey: photoKey)
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    // MARK: Fetch All Pins in MapVC
    
    func fetchAllPlants(completion: @escaping (PlantsResult) -> Void) {
        
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        let moc = storeContainer.viewContext
        
        fetchRequest.fetchBatchSize = 10
        
        moc.perform {
            do {
                let allPlants = try moc.fetch(fetchRequest)
                completion(.success(allPlants))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Core Data
    
    func saveContext () {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: - Helper methods to create core data from seed.json
    
    func importJSONSeedDataIfNeeded() {
        
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        let count = try? self.managedContext.count(for: fetchRequest)
        
        guard let plantCount = count,
            plantCount == 0 else {
                return
        }
        
        importJSONSeedData()
    }
    
    func importJSONSeedData() {
        
        let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
        let jsonData = try! Data(contentsOf: jsonURL)
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [String: AnyObject]
            
            for jsonDictionary in jsonArray["plants"] as! [[String: AnyObject]] {
                let scientificName = jsonDictionary["scientificName"] as! String
                let commonNames = jsonDictionary["commonName"] as! [String]
                let location = jsonDictionary["location"] as! [String:AnyObject]
                let plantType = jsonDictionary["plantType"] as! String
                let climateZones = jsonDictionary["climateZones"] as! String
                let sunExposure = jsonDictionary["sunExposure"] as! String
                let waterNeeds = jsonDictionary["waterNeeds"] as! String
                let coordinate = location["coordinate"] as! [String:AnyObject]
                let latitude = coordinate["latitude"] as! Double
                let longitude = coordinate["longitude"] as! Double
                let photos = jsonDictionary["photos"] as! [[String:Any]]
                
                let plant = Plant(context: self.managedContext)
                
                plant.scientificName = scientificName
                plant.commonName = commonNames[0]
                plant.latitude = latitude
                plant.longitude = longitude
                plant.plantType = plantType
                plant.climateZones = climateZones
                plant.sunExposure = sunExposure
                plant.waterNeeds = waterNeeds
                
                for photo in photos {
                    let image = Photo(context: self.managedContext)
                    image.remoteURL = NSURL(string: photo["remoteURL"] as! String)
                    image.photoID = UUID().uuidString // Add unique photoID
                    plant.addToPhoto(image)
                }
                
            }
            
            self.saveContext()
            
        } catch let error as NSError {
            print("Error importing plants: \(error)")
        }
    }
    
}
