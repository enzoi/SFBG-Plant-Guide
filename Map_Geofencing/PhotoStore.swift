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
        
        if let imageData = photo.imageData {
            
            let image = UIImage(data: imageData as Data)
            
            OperationQueue.main.addOperation {
                completion(.success(image!))
            }
            
        } else {
            
            // Otherwise, get an image using URL
            let photoURL = photo.remoteURL
            let request = URLRequest(url: photoURL! as URL)
            
            let task = session.dataTask(with: request) { (data, response, error) -> Void in
                
                let result = self.processImageRequest(data: data, error: error)
                
                // After get the imageData, store the image in core data
                if case let .success(image) = result {
                    
                    // Turn image into JPEG data
                    if let data = UIImageJPEGRepresentation(image, 0.3) {
                        
                        // Write it to Core Data
                        let moc = self.managedContext
                        
                        moc.perform {
                            photo.imageData = data as NSData
                            
                            do {
                                try moc.save()
                            } catch {
                                moc.rollback()
                            }
                        }
                    }
                }
                
                OperationQueue.main.addOperation {
                    completion(result)
                }
            }
            task.resume()
        }
    }
    
    // MARK: Fetch All Pins in MapVC
    
    func fetchAllPlants(completion: @escaping (PlantsResult) -> Void) {
        
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        let moc = storeContainer.viewContext
        
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
    
}
