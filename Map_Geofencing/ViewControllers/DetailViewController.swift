//
//  DetailViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 11/28/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {
 
    var tableView: UITableView!
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var spinner: UIActivityIndicatorView!
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    var photoStore: PhotoStore!
    var plant: Plant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        scrollView = UIScrollView(frame: CGRect(x:0, y: 0, width: displayWidth, height: 250))
        scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: 1.0)
        scrollView.backgroundColor = UIColor.darkGreen20
        scrollView.isPagingEnabled = true
        view.addSubview(self.scrollView)
        
        pageControl = UIPageControl(frame:CGRect(x: (displayWidth - 200)/2, y: 220, width: 200, height: 30))
        view.addSubview(pageControl)
        pageControl.isHidden = true
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        spinner.center = scrollView.center
        view.addSubview(spinner)
        spinner.startAnimating()
        
        tableView = UITableView(frame: CGRect(x: 0, y: 250, width: displayWidth, height: displayHeight - 250))
        scrollView.delegate = self
        
        configurePageControl()
        
        let photos = Array(plant.photo!) as! [Photo]
        
        let dispatchGroup = DispatchGroup()
        
        var index = 0

        for photo in photos {
            
            print("photo: ", photo)
            
            dispatchGroup.enter()
            
            photoStore.fetchImage(for: photo, completion: { (result) in
                
                if case let .success(image) = result {
                    
                    self.frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
                    self.frame.size = self.scrollView.frame.size
                    
                    let subView = UIImageView(frame: self.frame)
                    subView.contentMode = .scaleAspectFit
                    subView.image = image
                    subView.contentMode = .scaleAspectFill
                    subView.clipsToBounds = true
                    
                    self.scrollView.addSubview(subView)
                    self.spinner.stopAnimating()
                    
                    index += 1
                    
                    dispatchGroup.leave()
                }
            })
            
            performUIUpdatesOnMain {

                dispatchGroup.notify(queue: .main) {

                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(photos.count), height: 1.0)

                    if self.pageControl.numberOfPages > 1 {
                        self.pageControl.isHidden = false
                    }
                    
                    self.tableView.reloadData()
                }
            }

        }
        
        // The collapsible sections and view model for table view below and 
        // the detail table view cells folder refers to the solution from
        // https://medium.com/ios-os-x-development/ios-how-to-build-a-table-view-with-collapsible-sections-96badf3387d0
        
        // View model for table view
        let viewModel = PlantViewModel(plant: plant)
        
        viewModel.reloadSections = { [weak self] (section: Int) in
            self?.tableView.beginUpdates()
            self?.tableView.reloadSections([section], with: .fade)
            self?.tableView.endUpdates()
        }

        // Set up table view and register cells
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
     
        tableView.register(PlantNameTableViewCell.nib, forCellReuseIdentifier: PlantNameTableViewCell.identifier)
        tableView.register(PlantPropertiesTableViewCell.nib, forCellReuseIdentifier: PlantPropertiesTableViewCell.identifier)
        tableView.register(HeaderView.nib, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)

        self.view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func configurePageControl() {

        self.pageControl.numberOfPages = (plant.photo?.allObjects.count)!
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.70)
        self.pageControl.currentPageIndicatorTintColor = UIColor.white
        self.pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
}
