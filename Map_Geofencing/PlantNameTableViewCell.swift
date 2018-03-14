//
//  PlantNameTableViewCell.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 12/9/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

protocol HandleButtonPressedDelegate: class { // Define Protocol
    func buttonPressed(buttonName: String)
}

class PlantNameTableViewCell: UITableViewCell {

    @IBOutlet weak var scientificNameLabel: UILabel!
    @IBOutlet weak var commonNameLabel: UILabel!
    
    weak var delegate: HandleButtonPressedDelegate?
    var plant: Plant!
    var item: PlantViewModelNamesItem? {
        didSet {
            guard let item = item else { return }
            plant = item.plant
            scientificNameLabel?.text = item.plant.scientificName
            commonNameLabel?.text = item.plant.commonName
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAccessoryView()
    }
    
    func setupAccessoryView() {

        let playButton = UIButton(type: .custom)
        playButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        playButton.setImage(#imageLiteral(resourceName: "icons8-headphones-filled-100"), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        
        let flickrButton = UIButton(type: .custom)
        flickrButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        flickrButton.setImage(#imageLiteral(resourceName: "icons8-flickr-96"), for: .normal)
        flickrButton.addTarget(self, action: #selector(flickrButtonTapped), for: .touchUpInside)

        let wikiButton = UIButton(type: .custom)
        wikiButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        wikiButton.setImage(#imageLiteral(resourceName: "icons8-wikipedia-100"), for: .normal)
        wikiButton.addTarget(self, action: #selector(wikiButtonTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [playButton, flickrButton, wikiButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        self.addSubview(stackView)
        stackView.anchor(top: nil, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 90, height: 25)
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        layoutSubviews()
    }

    @objc func playButtonTapped(sender: UIButton) {
        // TODO: add play functionality
        let audioVC = AudioPlayController()
        audioVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        let presentingVC = self.parentViewController as! DetailViewController
        audioVC.plant = presentingVC.plant
        presentingVC.tabBarController?.tabBar.isHidden = true
        presentingVC.navigationController?.present(audioVC, animated: true, completion: nil)
    }
    
    @objc func flickrButtonTapped(sender: UIButton) {
        let photoAlbumVC = PhotoAlbumViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let presentingVC = self.parentViewController as! DetailViewController
        photoAlbumVC.photoStore = presentingVC.photoStore
        photoAlbumVC.plant = presentingVC.plant
        presentingVC.navigationController?.pushViewController(photoAlbumVC, animated: true)
    }
    
    @objc func wikiButtonTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webVC = storyboard.instantiateViewController(withIdentifier :"webViewController") as! WebViewController
        let baseUrlString = "https://en.wikipedia.org/wiki/"
        
        guard let plantNameArray = self.commonNameLabel.text?.lowercased().components(separatedBy: " ") else { return }
        let searchURL = plantNameArray.joined(separator: "_")
        
        webVC.url = URL(string: baseUrlString + searchURL)
        
        let presentingVC = self.parentViewController as! DetailViewController
        presentingVC.navigationController?.pushViewController(webVC, animated: true)
    }
    
}
