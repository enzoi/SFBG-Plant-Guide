//
//  PhotoViewCell.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 3/8/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    var spinner = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.frame.width, height: self.frame.height)
        addSubview(spinner)
        spinner.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        update(with: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        update(with: nil)
    }

    func update(with image: UIImage?) {

        if let imageToDisplay = image {
            spinner.stopAnimating()
            DispatchQueue.main.async {
                self.photoImageView.image = imageToDisplay
            }
        } else {
            spinner.startAnimating()
            photoImageView.image = nil
        }

    }
}
