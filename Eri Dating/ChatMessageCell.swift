//
//  ChatMessageCell.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 02/03/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController:ChatLogControllerCVC?
    var message:Message?
    
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        aiv.hidesWhenStopped = true
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    
    lazy var playButton:UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play")
        button.tintColor = UIColor.white
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        
        return button
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Sample text"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        
        //tv.isUserInteractionEnabled = false
        tv.isEditable = false

        return tv
    }()
    
    var playerLayer:AVPlayerLayer?
    var player:AVPlayer?

    /*
    func removeAVPlayerLayer() {
        player?.pause()
        activityIndicatorView.stopAnimating()
        playerLayer?.removeFromSuperlayer()
        playButton.isHidden = false
        messageImageView.isHidden = false
    }*/
    
    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        activityIndicatorView.stopAnimating()
    }
    
    
    let bubbleView: UIView = {
        let view = UIView()
        //let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 80))
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noprofilepic")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy var messageImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return imageView
    }()
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil {
            print("Not playing video.")
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
        
    }
    func newPlayMethod(url: URL) {
        
        player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        let keyWindow = UIApplication.shared.keyWindow
        
        keyWindow?.rootViewController?.present(playerViewController, animated: true, completion: {
            playerViewController.player?.play()
        })
        
    }
    @objc func handlePlay() {
        if let videoUrl = message?.videoUrl, let url = URL(string: videoUrl) {
            newPlayMethod(url: url)
            
            /*
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            player = AVPlayer(url: url)
            
            NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying(notif:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            
            playerLayer = AVPlayerLayer(player: player)
            
            playerLayer?.frame = bubbleView.bounds
            
            //playerLayer?.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(-M_PI)))
            
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            messageImageView.isHidden = true*/
        }
    }
    /*
    @objc func didFinishPlaying(notif: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: notif.object)
        removeAVPlayerLayer()
    }*/
    
    static let blueColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1.0)
    static let grayColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor:NSLayoutConstraint?
    var bubbleViewLeftAnchor:NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleView.addSubview(messageImageView)
        
        // message image view constraints
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        
        // play button constraints
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(activityIndicatorView)
        
        // play button constraints
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // profile constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        // bubbleview constraints
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        //bubbleViewLeftAnchor?.isActive = false - Will be anchored dynamically
        
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        // Setting the layout priority allowed AutoLayout to make decisions instead of throwing errors for breaking layout
        
        bubbleWidthAnchor?.priority = UILayoutPriority.init(900)
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        // ios 9 contraints for textview
        // x, y, w, h
        //textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        //textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
