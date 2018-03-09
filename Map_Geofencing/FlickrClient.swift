//
//  FlickrClient.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 3/8/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum FlickrError: Error {
    case invalidJSONData
}

enum ImagesResult {
    case success([URL])
    case failure(Error)
}

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}


class FlickrClient : NSObject {
    
    override init() {
        super.init()
    }
    
    // MARK: Flickr Client methods

    // Get UIImages from Image URLs
    func getFlickrPhotos(fromJSON data: Data) -> ImagesResult {
        
        // parse the data
        let parsedResult: [String:AnyObject]!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                // displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return .failure(FlickrError.invalidJSONData)
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                // displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return .failure(FlickrError.invalidJSONData)
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: Any]] else {
                // displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return .failure(FlickrError.invalidJSONData)
            }
            
            if photosArray.count == 0 {
                return .failure(FlickrError.invalidJSONData)
            }
            
            var finalURLs = [URL]()
            
            for photoItem in photosArray { // photoItem [String: AnyObject]
                
                if let imageURL = getFlickrPhoto(fromJSON: photoItem) {
                    
                    finalURLs.append(imageURL)
                }
            }
            
            return .success(finalURLs)
            
        } catch let error {
            return .failure(error)
        }
        
    }
    
    // Get UIImage (Called inside getFlickrPhotos(fromJSON data:)
    func getFlickrPhoto(fromJSON json: [String: Any]) -> URL? {

        guard
            let photoID = json["id"] as? String,
            let url = json["url_m"] as? String
            else {
                return nil
        }
        
       return URL(string: url)
    }
    
    // Convert ImageData to UIImage
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
    
}
