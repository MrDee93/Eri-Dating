//
//  UserImage.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 16/12/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import Foundation
import UIKit

class CameraPicker: NSObject {
    weak var viewController:MyProfileVC!

   // weak var delegate
    //var delegate:ImagePickerCompletedDelegate!
    
   // var imagePicker:UIImagePickerController!
    
    init(withVC viewcontroller:UIViewController) {
        super.init()
        
        self.viewController = viewcontroller as! MyProfileVC
        //self.imagePicker = UIImagePickerController()
        //self.imagePicker.delegate = self
        
        
    }
    override init() {
        super.init()
       // imagePicker = UIImagePickerController()
        //imagePicker.delegate = self
    }
    
    deinit {
        self.viewController = nil
    }
    
    
    func presentFirstPictureOption() {
        let selectPictureOptionsSheet = UIAlertController(title: "Select an option", message:nil, preferredStyle: .actionSheet)
        let profileOption = UIAlertAction(title: "Set New Profile Picture", style: .default) { (action) in
            // Set new profile pic
            self.viewController.selectedTypeOfPhoto = .ProfilePicture
            self.presentPictureOptions()
        }
        let cameraOption = UIAlertAction(title: "Add new photo", style: .default, handler:{ (action) -> Void in
            // Add another photo
            self.viewController.selectedTypeOfPhoto = .NewPhoto
            self.presentPictureOptions()
        })
        let cancelOption = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        selectPictureOptionsSheet.addAction(profileOption)
        selectPictureOptionsSheet.addAction(cameraOption)
        selectPictureOptionsSheet.addAction(cancelOption)
        
        self.viewController.present(selectPictureOptionsSheet, animated: true, completion: nil)
        
    }
    func presentPictureOptions() {
        // User chose to add more photos
        //self.viewController.selectedTypeOfPhoto = .NewPhoto
        let selectPictureOptionsSheet = UIAlertController(title: "Select an option", message:nil, preferredStyle: .actionSheet)
        let cameraOption = UIAlertAction(title: "Take a Photo", style: .default, handler:{ (action) -> Void in
            // Launch camera
            self.launchCamera()
        })
        let libraryOption = UIAlertAction(title: "Select photo from Library", style: .default, handler:{ (action) -> Void in
            // Present library photos to pick from.
            self.launchSavedLibrary()
            })
        let cancelOption = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        selectPictureOptionsSheet.addAction(cameraOption)
        selectPictureOptionsSheet.addAction(libraryOption)
        selectPictureOptionsSheet.addAction(cancelOption)
        
        self.viewController.present(selectPictureOptionsSheet, animated: true, completion: nil)
    
    }
    
    func launchCamera() {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker:UIImagePickerController = UIImagePickerController()
                imagePicker.delegate = self.viewController
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front
                imagePicker.cameraCaptureMode = .photo
                imagePicker.allowsEditing = true
                
                self.viewController.present(imagePicker, animated: true, completion: nil)
            } else {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
                    let alert = UIAlertController(title: "Camera Unavailable", message: "Unable to find a camera on your device. You may select a photo from your photos library", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.launchSavedLibrary()
                    })
                    alert.addAction(okButton)
                } else {
                    let alert = UIAlertController(title: "Camera Unavailable", message: "Unable to find a camera or photos on your device.", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "Ok", style: .default, handler:nil)
                    alert.addAction(okButton)
                    self.viewController.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    func launchSavedLibrary() {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self.viewController
        //imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        
        self.viewController.present(imagePicker, animated: true, completion: nil)
    }
    
}
