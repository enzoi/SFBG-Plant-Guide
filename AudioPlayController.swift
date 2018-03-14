//
//  AudioPlayController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 3/13/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayController: UIViewController {
    
    let audioView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        return view
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons8-circled-play-100"), for: .normal)
        button.tintColor = UIColor.darkGray
        return button
    }()
    
    let pauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons8-circled-pause-100"), for: .normal)
        button.tintColor = UIColor.darkGray
        return button
    }()
    
    let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons8-circled-stop-100"), for: .normal)
        button.tintColor = UIColor.darkGray
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12.5
        button.layer.masksToBounds = true
        button.setImage(#imageLiteral(resourceName: "icons8-cancel-104"), for: .normal)
        button.tintColor = UIColor.lightGray
        return button
    }()
    
    var plant: Plant!
    var synth: AVSpeechSynthesizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.grayBackground
        
        setUpButtons()
        
    }
    
    private func setUpButtons() {
        
        pauseButton.isEnabled = false
        stopButton.isEnabled = false
        
        synth = AVSpeechSynthesizer()
        
        view.addSubview(audioView)
        audioView.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: view.frame.width - 30, height: 60)
        audioView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [stopButton, pauseButton, playButton])
        stackView.distribution = .fillProportionally
        
        stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pause), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        
        audioView.addSubview(stackView)
        stackView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 135, height: 45)
        stackView.centerXAnchor.constraint(equalTo: audioView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: audioView.centerYAnchor).isActive = true
        
        audioView.addSubview(dismissButton)
        dismissButton.anchor(top: audioView.topAnchor, left: nil, bottom: nil, right: audioView.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 25, height: 25)
        
        dismissButton.addTarget(self, action: #selector(dismissAudioController), for: .touchUpInside)
        
    }
    
    @objc private func dismissAudioController() {
        synth?.stopSpeaking(at: .immediate)
        presentingViewController?.tabBarController?.tabBar.isHidden = false
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func play(_ sender: Any) {
        
        if stopButton.isEnabled == false {
            
            guard let string = plant.plantDescription else { return }
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synth?.speak(utterance)
            
            playButton.isEnabled = false
            pauseButton.isEnabled = true
            stopButton.isEnabled = true
            
        } else { // paused after started playing
            
            synth?.continueSpeaking()
            playButton.isEnabled = false
            pauseButton.isEnabled = true
            stopButton.isEnabled = true
            
        }
        
    }
    
    @objc private func pause(_ sender: Any) {
        synth?.pauseSpeaking(at: .immediate)
        pauseButton.isEnabled = false
        playButton.isEnabled = true
    }
    
    @objc private func stop(_ sender: Any) {
        synth?.stopSpeaking(at: .immediate)
        stopButton.isEnabled = false
        pauseButton.isEnabled = false
        playButton.isEnabled = true
    }
    
}
