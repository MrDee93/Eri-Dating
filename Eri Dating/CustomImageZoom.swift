//
//  CustomImageZoom.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 24/10/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit

class CustomImageZoom {
    var startingImageView:UIImageView!
    
    var startingFrame: CGRect?
    var blackBackgroundView:UIView?
    
    // Custom zooming logic - credit to Letsbuildthatapp from YouTube
    func performZoomInForStartingImageView(startingImageView: UIImageView) -> UIImageView {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        //zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(self.blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                //self.inputContainerView.alpha = 0
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                zoomingImageView.contentMode = .scaleAspectFit
                
            }, completion: nil)
        }
        return zoomingImageView
    }
    // Zoom in with Option to delete photo
    func performZoomInWithDeleteOptionForStartingImageView(startingImageView: UIImageView) -> UIImageView {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        //zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(self.blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
           
            let deleteImageViewButton = self.createDeleteImage()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                //self.inputContainerView.alpha = 0 - There is no inputContainerview here. Only on ChatLogController Views.
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                zoomingImageView.contentMode = .scaleAspectFit
                
                self.blackBackgroundView!.addSubview(deleteImageViewButton)
 
                self.setDeleteImageConstraints(deleteImageView: deleteImageViewButton)
            }, completion: nil)
        }
        return zoomingImageView
    }
    func setDeleteImageConstraints(deleteImageView: UIImageView) {
        deleteImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        deleteImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        deleteImageView.bottomAnchor.constraint(equalTo: (self.blackBackgroundView?.bottomAnchor)!, constant: -50).isActive = true
        deleteImageView.centerXAnchor.constraint(equalTo: (self.blackBackgroundView?.centerXAnchor)!).isActive = true
    }
    
    @objc func deleteImageAction() {
        NotificationCenter.default.post(name: NSNotification.Name.init("DeletePhoto"), object: nil)
    }
    
    func createDeleteImage() -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 250, y: 500, width: 80, height: 80))
        
        imageView.image = UIImage(named: "garbage-icon-small")
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteImageAction)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentScaleFactor = CGFloat(0.2)
        
        return imageView
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            // need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                //self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                // Testing this new function of remove blackbackgroundview from superview to remove the trash can image
                self.blackBackgroundView?.removeFromSuperview()

            })
        }
    }
    func handleZoomOutImageView(zoomOutImageView: UIImageView) {
            // need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                //self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                // Testing this new function of remove blackbackgroundview from superview to remove the trash can image
                self.blackBackgroundView?.removeFromSuperview()
            })
    }
}
