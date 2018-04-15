//
//  ProfilePhotoChecker.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 19/01/2018.
//  Copyright © 2018 Dayan Yonnatan. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage


class ProfilePhotoChecker {
    static func setNewProfilePhoto(uid:String) {
        // Grab the file from other_photos storage and move to user_profile_pics and rename to user uid
        let storageRef = Storage.storage().reference(forURL: "gs://eri-dating.appspot.com")
        let imageRef = storageRef.child("user_other_photos/\(uid)/")
        
        imageRef.getData(maxSize: (5 * 1024 * 1024)) { (data, error) in
            if error == nil && data != nil {
                
                // Got the data, now to store in user_profile_pics/uid.jpg and rename the users/profileimageurl with new download url
                // then use Users method to remove the old photo from other_photos DB and other_photos Storage
            }
        }
        
        
        let newImageRef = storageRef.child("user_profile_pics/\(uid).jpg")
        
        
        // then remove the item from other_photos (if its the only item, remove folder)
        // then add to users/ under profileimageurl with the new download url
    }
    
    static func checkIfUserHasOtherPhotos(_ uid:String) {
        print("Checking if user has other photos...")
        let databaseRef = Database.database().reference().child("users").child(uid).child("other_photos")
        
        databaseRef.observeSingleEvent(of: .value) { (snapshot) in
            // guard incase theres no data here..
            guard let snapshotValues = snapshot.value as? NSDictionary else  {
                return
            }
            for values in snapshotValues {
                let value = values.value as? NSDictionary
                print("key: \(values.key)   url: \(value?.value(forKey: "imageUrl"))")
            }
        }
    }
    
    static func checkIfUserHasProfilePhoto(_ uid:String) {
        let databaseRef = Database.database().reference().child("users").child(uid)
        
        databaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaryOfValues = snapshot.value as? NSDictionary {
                
                if let profileimageurlString = dictionaryOfValues.value(forKey: "profileimageurl") as? String {
                    if profileimageurlString != nil {
                        // user has profile pic
                        print("User has profile pic")
                        
                        return
                    } else {
                        // no profile pic
                        print("No profile pic!")
                        self.checkIfUserHasOtherPhotos(uid)
                    }
                } else {
                    print("No profile pic!")
                    self.checkIfUserHasOtherPhotos(uid)
                }
            } 
        }
        // check if user has profile photo (users/profileimageurl is not nil)
        
        // if yes, return out of function
        
        
        // if no, check if user has other_photos
        // if other_photos exists, allow user to select which one to use as profile photo
    }
    
}
