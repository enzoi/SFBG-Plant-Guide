//
//  MapViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 10/31/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
import UserNotificationsUI

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [MKAnnotation]()
    var photoStore: PhotoStore!
    var locationManager: CLLocationManager!
    var fetchedPlants = [Plant]()
    var userCurrentLocation:CLLocation?

    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var loadingLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        
        let sfbgLocation = CLLocation(latitude: 37.767527, longitude: -122.469890)
        centerMapOnLocation(location: sfbgLocation)
        
        // Get photoStore from TabBarController
        let tabBar = self.tabBarController as! TabBarController
        self.photoStore = tabBar.photoStore
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        
        performUIUpdatesOnMain() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Check if there is an update then fetch again
        mapView.removeAnnotations(mapView.annotations)
        
        if fetchedPlants.count == 0 {
            fetchAllPlantMarkers()
        } else {
            self.mapView.addAnnotations(self.annotations)
        }
        
    }
    
    
    // Fetch all saved pins with annotation
    func fetchAllPlantMarkers() {
  
        mapView.delegate = self
        
        self.showActivityIndicator(vc: self, view: self.view)
        
        // Get all plants
        photoStore.fetchAllPlants() { (plantsResult) in
            
            switch plantsResult {
                
            case let .success(plants):
                
                self.fetchedPlants = plants
                
                if self.fetchedPlants.count > 0 {
                    
                    for plant in self.fetchedPlants {
                        
                        let pinAnnotation = plant.getPinAnnotationsFromPin(plant: plant)
                        
                        let photos = plant.photo?.allObjects as! [Photo]

                        if let photo = photos.first {
                            
                            self.photoStore.fetchImage(for: photo, completion: { (result) in
                                switch result {
                                    case .success:
                                        print("fetch sucess")
                                        self.hideActivityIndicator(vc: self, view: self.view)
                                    case let .failure(error):
                                        self.showAlertWithError(title: "Error fetching data", error: PhotoError.imageCreationError)
                                        print("Error fetching image for photo: \(error)")
                                }
                            })
                        }
                        
                        self.annotations.append(pinAnnotation)
                        
                    }
                    
                    performUIUpdatesOnMain {
                        self.mapView.addAnnotations(self.annotations)
                        // self.hideActivityIndicator(vc: self, view: self.view)
                    }
                    
                } else {
                    print("Nothing to fetch")
                }
                
            case .failure(_):
                self.fetchedPlants = []
            }
        }
        
    }
    
    @IBAction func segmentedControlAction(sender: UISegmentedControl!) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .satellite
        }
    }

}

// MARK: - Map View Delegate

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
     
        let identifier = "pin"
        var view: MKAnnotationView
        
        if annotation is MKUserLocation {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            return view
        }
        
        // annotation is PinAnnotation
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            
            pinView.annotation = annotation
            view = pinView
            
            return view
            
        } else {
            
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.image = #imageLiteral(resourceName: "icons8-oak-tree-100")
            
            var frame = view.frame
            frame.size.height = 35
            frame.size.width = 35
            view.frame = frame
            
            let plant = fetchedPlants.filter { $0.scientificName == annotation.title! }.first
            let photos = plant?.photo?.allObjects as! [Photo]
            
            if let photo = photos.first {

                let plantImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
                plantImageView.layer.cornerRadius = 22.5
                plantImageView.layer.masksToBounds = true
                
                photoStore.fetchImage(for: photo, completion: { (result) in
                    
                    if case let .success(image) = result {
                        
                        performUIUpdatesOnMain() {
                            plantImageView.image = image
                            view.leftCalloutAccessoryView = plantImageView
                        }
                    }
                })
            }
        
            // Button to lead to detail view controller
            let arrowButton = UIButton(frame: CGRect.init(x: 200, y: 25, width: 25, height: 25))
            arrowButton.setImage(UIImage(named: "icons8-Forward Filled-50"), for: .normal)
            view.rightCalloutAccessoryView = arrowButton
            
            return view
        }

    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        if let index = fetchedPlants.index(where: { $0.scientificName == (view.annotation?.title)! }) {
            let selectedPlant = fetchedPlants[index]
            detailVC.plant = selectedPlant
            detailVC.photoStore = photoStore
        }
        
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
}


// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("location manager didChangeAuth called")
        mapView.showsUserLocation = status == .authorizedWhenInUse
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            
            // Requesting Authorization for User Interactions only when location service granted
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            
            photoStore.fetchAllPlants() { (plantsResult) in
                
                switch plantsResult {
                    
                case let .success(plants):
                    
                    // Get plant with specific user & get favorite plants
                    let plant = plants.filter { $0.scientificName! == region.identifier }.first!
                    self.handleEvent(forRegion: region, plant: plant)
                    
                case .failure(_):
                    print("No plants")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        let _ = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)

         locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.01, 0.01))
        mapView.setRegion(coordinateRegion, animated: true)
    }

}

extension MapViewController: UNUserNotificationCenterDelegate {
    
    // MARK: - Region monitoring event handler
    
    // The geofencing related codes below refers to the solution from
    // https://www.raywenderlich.com/136165/core-location-geofencing-tutorial
    
    //  The notification related codes below refers to the solution from
    // https://stackoverflow.com/questions/39103095/unnotificationattachment-with-uiimage-or-remote-url
    // and https://useyourloaf.com/blog/local-notifications-with-ios-10/
    
    func handleEvent(forRegion region: CLRegion!, plant: Plant) {
        
        // Create notification contents
        let content = UNMutableNotificationContent()
        content.title = "Nearby Plant"
        content.subtitle = plant.scientificName!
        content.body = "Find your plant nearby"
        
        let openAction = UNNotificationAction(identifier:"open",
                                              title:"Open",options:[])
        
        let category = UNNotificationCategory(identifier: "actionCategory",
                                              actions: [openAction],
                                              intentIdentifiers: [], options: [])
        
        content.categoryIdentifier = "actionCategory"
        
        UNUserNotificationCenter.current().setNotificationCategories(
            [category])
        
        let photos = Array(plant.photo!) as! [Photo]
        guard let photo = photos.first else { return }
        
        if let attachment = UNNotificationAttachment.create(identifier: plant.scientificName!, imageData: photo.imageData! as Data, options: nil) {
            content.attachments = [attachment]
        }
        
        // Deliver the notification in one seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        
        let requestIdentifier = "plantNotification"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request) { (error) in
            
            if (error != nil){
                print(error?.localizedDescription ?? "something wrong")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "open":
            
            // Open Detail View Controller
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            guard let tabBarController = appDelegate.window!.rootViewController as? TabBarController else { return }
            
            if let favoriteVC = tabBarController.viewControllers?[2].navigationController?.viewControllers.first {
                
                let storyboard = UIStoryboard (name: "Main", bundle: nil)
                let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                
                favoriteVC.navigationController?.pushViewController(detailVC, animated: true)
            }
            
        default:
            break
        }
        completionHandler()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if notification.request.identifier == "plantNotification" {
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}


// MARK: - Custom Pin Annotation

class PinAnnotation : NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var subtitle: String?
    
    init(plant: Plant) {
        self.coordinate = plant.coordinate
    }
    
}

