//
//  PlantPhotosTableViewCell.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/10/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class PlantPhotosTableViewCell: UITableViewCell, UIScrollViewDelegate {
    
    // TODO: page control still not visible...needs to fix it

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var pages = [UIView?]()
    var transitioning = false
    var imageArray = [UIImage]()
    
    // Need to figure out page view controller for multiple photos
    var item: PlantViewModelPhotosItem? {
        didSet {
            guard let item = item else {
                return
            }
            let photos = item.photos
            imageArray = photos.map{ UIImage(data: $0.imageData! as Data, scale: 1.0)! }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        pages = [UIView?](repeating: nil, count: imageArray.count)
        pageControl.numberOfPages = imageArray.count
        pageControl.currentPage = 0
        pageControl.backgroundColor = .red
        pageControl.addTarget(self, action: #selector(pageChange), for: UIControlEvents.valueChanged)
        
        scrollView.contentSize.width = scrollView.frame.width * CGFloat(imageArray.count)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        // When photos item changes update scroll view images
        for i in 0..<imageArray.count {
            
            let imageView = UIImageView()
            imageView.image = imageArray[i]
            let xPosition = self.scrollView.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: 375, height: 300)
            
            scrollView.addSubview(imageView)
        }
        
        contentView.addSubview(scrollView)
        
    }
    
    override func layoutSubviews() {
    
        pages = [UIView?](repeating: nil, count: imageArray.count)
        pageControl.numberOfPages = imageArray.count
        pageControl.currentPage = 0
        pageControl.backgroundColor = .red
        pageControl.addTarget(self, action: #selector(pageChange), for: UIControlEvents.valueChanged)
        
        scrollView.contentSize.width = scrollView.frame.width * CGFloat(imageArray.count)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        // When photos item changes update scroll view images
        for i in 0..<imageArray.count {
            
            let imageView = UIImageView()
            imageView.image = imageArray[i]
            let xPosition = self.scrollView.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: 375, height: 300)
            
            scrollView.addSubview(imageView)
        }
        
        contentView.addSubview(scrollView)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func pageChange(_ sender: AnyObject) -> (){
        
        let x = CGFloat(sender.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }

}
