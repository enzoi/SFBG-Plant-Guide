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
    
    var imageView = UIImageView()
    var spinner = UIActivityIndicatorView()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        update(with: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        update(with: nil)
    }

    func update(with image: UIImage?) {

        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }

    }
}
