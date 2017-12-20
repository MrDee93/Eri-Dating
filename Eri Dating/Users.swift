//
//  Users.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 13/12/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class Users {
    static func createUserFromCoreDataDB(userDB:UsersDB) -> EDUser {
        let user:EDUser = EDUser()
        
        if let usersDBGender = userDB.gender {
            user.gender = usersDBGender
        }
        if let usersDBName = userDB.name {
            user.name = usersDBName
        }
        if let usersDBCountry = userDB.country {
            user.country = usersDBCountry
        }
        if let usersDBUID = userDB.userID {
            user.id = usersDBUID
        }
        if let usersDOB = userDB.dateofbirth {
            user.DOB = usersDOB
        }
        if let usersDBCity = userDB.city {
            user.city = usersDBCity
        }
        if let usersProfilePicUrl = userDB.profilePicUrl {
            user.profilePicUrl = usersProfilePicUrl
        }
        if let usersDBAbout = userDB.about {
            user.about = usersDBAbout
        }
        if let usersRelationshipStatus = userDB.relationship_status {
            user.relationship_status = usersRelationshipStatus
        }
        if let usersLookingFor = userDB.looking_for {
            user.looking_for = usersLookingFor
        }
        // FIXME: This is where the UsersDB class turns into a User class. Create a method to simplify this mess to be re-used elsewhere. Preferably the User class using a static method or something.
        return user
    }
    
    static var usersInDB:[EDUser] = [EDUser]()

    static func clearUsersFromDB(appDelegate:AppDelegate) {
        var fetchedData:[UsersDB]

        do {
            fetchedData = try appDelegate.persistentContainer.viewContext.fetch(UsersDB.fetchRequest())
        } catch {
            print("Error clearing Users from DB")
            return
        }
        
        var integer:Int = 0
        
        for(_, element) in fetchedData.enumerated() {
            DispatchQueue.main.async {
            appDelegate.persistentContainer.viewContext.delete(element)
            }
            integer = integer + 1
        }
        DispatchQueue.main.async {
            appDelegate.saveContext()
        }
    }

    
    static func isEqualToUserEmail(myEmail:String, fetchedEmail:String) -> Bool {
        if(fetchedEmail.caseInsensitiveCompare(myEmail) == ComparisonResult.orderedSame) {
            //print("Same email!")
            return true
        } else {
            return false
        }
    }
    static func isEqualTo(_ compareString:String, _ compareStringTwo:String) -> Bool {
        if (compareString.compare(compareStringTwo) == ComparisonResult.orderedSame) {
            return true
        }
        return false
    }
    static func getUsersFromDB(appDelegate:AppDelegate) {
        /*
         Refactor to obtain currentUser from FIRAuth.currentUser instead of appdelegate
         Compare currentUser.uid to UID of fetched user instead of Email????
         */
        
        let ref = Database.database().reference().child("users")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let dictionary = snapshot.value as! NSDictionary
            
            dictionary.enumerateKeysAndObjects({ (key, obj, stop) in
                let object = obj as! NSDictionary
                let objectKey = key as! String
                if (!self.isEqualTo(objectKey, appDelegate.activeUser.uid)) {
                //if (!self.isEqualToUserEmail(myEmail: appDelegate.activeUser.email!, fetchedEmail: object.value(forKey: "email") as! String)) {
                    appDelegate.persistentContainer.viewContext.perform({
                        let newUser:UsersDB = NSEntityDescription.insertNewObject(forEntityName: "UsersDB", into: appDelegate.persistentContainer.viewContext) as! UsersDB
                        newUser.name = object.value(forKey: "name") as? String
                        newUser.dateofbirth = object.value(forKey: "dateofbirth") as? String
                        newUser.country = object.value(forKey: "country") as? String
                        newUser.city = object.value(forKey: "city") as? String
                        newUser.userID = object.value(forKey: "uid") as? String
                        if let about = object.value(forKey: "about") as? String {
                            newUser.about = about
                        }
                        if let profilePicUrl = object.value(forKey: "profileimageurl") as? String {
                            newUser.profilePicUrl = profilePicUrl
                        }
                        if let relationshipstatus = object.value(forKey: "relationship_status") as? String {
                            newUser.relationship_status = relationshipstatus
                        }
                        if let lookingfor = object.value(forKey: "looking_for") as? String {
                            newUser.looking_for = lookingfor
                        }
                        if let gender = object.value(forKey: "gender") as? String {
                            newUser.gender = gender
                        }
                        
                        appDelegate.saveContext()
                        NotificationCenter.default.post(name: NSNotification.Name.init("FetchData"), object:nil)
                    })
                }
            })
        }, withCancel: nil)
    }
    
    static func updateUserFirebaseNotificationToken(uid:String, token:String) {
        let ref = Database.database().reference().child("users").child(uid)
        let notifToken = ["notification_token":token]
            
        ref.updateChildValues(notifToken)
    }
     static func findUserDetails(_ uid:String) {
        var foundUser:Bool = false
        let ref = Database.database().reference().child("users")
        
         ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary {
                
                 dictionary.enumerateKeysAndObjects({ (key, object, stopPointer) in
                    if key as! String == uid {
                        if let dictionaryData = object as? NSDictionary {
                            if let capturedUID = dictionaryData["uid"] as? String {
                                if uid == capturedUID {
                                    if let usersName = dictionaryData["name"] as? String {
                                    foundUser = true
                                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "UserDetailsFound"), object: nil)
                                    }
                                    
                                }  } } } })   }
            if (!foundUser) {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "UserDetailsNotFound"), object: nil)
            }
        }
    }
    
    static func updateUserName(UID userUID:String, Name newName:String) {
        let ref = Database.database().reference().child("users")
        let childRef = ref.child(userUID)
        let values = ["name":newName] as [String:Any]
        childRef.updateChildValues(values)
    }
    static func updateRelationshipStatus(userUID:String, newStatus:String) {
        let ref = Database.database().reference().child("users")
        let childRef = ref.child(userUID)
        let values = ["relationship_status":newStatus] as [String:Any]
        childRef.updateChildValues(values)
    }
    static func updateLookingFor(userUID:String, newLookingFor:String) {
        let ref = Database.database().reference().child("users")
        let childRef = ref.child(userUID)
        let values = ["looking_for":newLookingFor] as [String:Any]
        childRef.updateChildValues(values)
    }
    
    static func updateUserLocation(UID userUID:String, Country country:String, City city:String) {
        let ref = Database.database().reference().child("users")
        let childRef = ref.child(userUID)
        let values = ["country":country, "city":city] as [String:Any]
        childRef.updateChildValues(values)
    }
    static func updateUserAboutInfo(UID userUID:String, About newAboutInfo:String) {
        let ref = Database.database().reference().child("users")
        let childRef = ref.child(userUID)
        let values = ["about":newAboutInfo] as [String : Any]
        childRef.updateChildValues(values)
    }
    // FIXME: Refactoring....23/11/17
    static func addUserToDB(email:String, name:String, dateOfBirth:String, country:String, userUID:String, gender:Gender) {
        addUserToDB(email: email, name: name, dateOfBirth: dateOfBirth, country: country, city: nil, userUID: userUID, gender:gender)
    }
    static func addUserToDB(userUID:String, values:Dictionary<String,String>) {
        let ref = Database.database().reference().child("users")
        let childRef = ref.child(userUID)
        
        childRef.updateChildValues(values) { (error, firebasereference) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    static func addUserToDB(email:String, name:String, dateOfBirth:String, country:String, city:String?, userUID:String, gender:Gender) {
        let ref = Database.database().reference().child("users")
        let childRef = ref.child(userUID)
        
        var usergender:String
        if gender == Gender.Female {
            usergender = "F"
        } else {
            usergender = "M"
        }
        
        let values:[String:Any]
        
        if city == nil {
            values = ["email":email, "name":name, "dateofbirth":dateOfBirth, "country":country, "uid":userUID, "gender":usergender] as [String:Any]
        } else {
            values = ["email":email, "name":name, "dateofbirth":dateOfBirth, "uid":userUID, "country":country, "city":city!, "gender":usergender] as [String:Any]
        }
        childRef.updateChildValues(values, withCompletionBlock:{ (error, databaseReference) in
            if error != nil {
                print(error!)
                return
            }
        })
    }
    static func addProfileImageUrlTo(uid: String, profileImageUrl: String) {
        let ref = Database.database().reference().child("users").child(uid)

        let value = ["profileimageurl": profileImageUrl]
        
        ref.updateChildValues(value)
    }
 
    static func getCurrentUID() -> String {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let userUID = appDelegate.activeUser.uid
        
        return userUID
    }
    
    
    
    static func downloadMyProfilePicture(_ sender: MyProfileVC) {
        weak var myProfileVC = sender
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let userUID = appDelegate.activeUser.uid
        
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://eri-dating.appspot.com")
        
        let profilePicReference = storageRef.child("user_profile_pics/\(userUID).jpg")

        _ = profilePicReference.getData(maxSize: (5 * 1024 * 1024), completion: { (data, error) -> Void in
            if(error == nil) {
                if(data != nil) {
                    myProfileVC?.profilePicture = UIImage(data: data!)
                }
            }
            if(error != nil && data == nil) {
                myProfileVC?.profilePicture = UIImage(named: "noprofilepic")
            }
        })
    }
    
    
    static func addPhotoToUserDB(userUID:String, pictureUrl:String, pictureFilename:String) {
        let ref = Database.database().reference().child("users").child(userUID).child("other_photos").childByAutoId()
        
        let value = ["imageUrl":pictureUrl, "imageFilename":pictureFilename]
        
        ref.updateChildValues(value) { (error, reference) in
            if error != nil {
                print(error!)
            }
        }
    }
    
    static func removePhotoFromUserDB(userUID:String, imageFolder:String) {
        let ref = Database.database().reference().child("users").child(userUID).child("other_photos").child(imageFolder)

        ref.removeValue()
    }
    // FIXME: Clean up code.
    static func findAndDeletePhotoWithFilename(filename:String, userUID:String) {
        let ref = Database.database().reference().child("users").child(userUID)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshotResults = snapshot.value as? NSDictionary else {
                return
            }
            
            for imageFolder in snapshotResults {
                let keyName = imageFolder.key as! String
                if keyName == "other_photos" {
                    for imageData in imageFolder.value as! NSDictionary {
                        let folderKey = imageData.key as! String // This is the folder name.
                        
                        let imageDataDictionary = imageData.value as! NSDictionary // Get the imageFilename & imageUrl dictionary datas
                        
                        let foundFilename = imageDataDictionary.value(forKey: "imageFilename") as! String
                        if filename.compare(foundFilename) == ComparisonResult.orderedSame {
                            self.removePhotoFromUserDB(userUID: userUID, imageFolder: folderKey)
                            self.removePhotoForUser(userID: userUID, imageFilename: filename)
                            NotificationCenter.default.post(name: NSNotification.Name.init("PhotoDeleted"), object: nil)
                        }
                        
                    }
                }
            }
        }
    }
    
    static func removePhotoForUser(userID:String, imageFilename:String) {
        // FIXME: Finish this remove photo feature
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://eri-dating.appspot.com")
        
        let imageRef = storageRef.child("user_other_photos/\(userID)/\(imageFilename).jpg")
        
        imageRef.delete { (error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    
    public static var arrayOfUserImages = [UserPhoto]()
    // FIXME: Requires testing
    static func getPhotosForUser(userUID:String) {
        self.arrayOfUserImages = [UserPhoto]()

        let ref = Database.database().reference().child("users").child(userUID).child("other_photos")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
                
            guard let snapshotResults = snapshot.value as? NSDictionary else {
                NotificationCenter.default.post(name: NSNotification.Name.init("NoPhotosFound"), object: nil)
                return
            }
                
            for val in snapshotResults {
                guard let dictValue = val.value as? NSDictionary else {
                    NotificationCenter.default.post(name: NSNotification.Name.init("NoPhotosFound"), object: nil)
                    return
                }
                
                let imageUrl = dictValue.value(forKey: "imageUrl") as! String
                
                if let imageFilename = dictValue.value(forKey: "imageFilename") as? String {
                    let userImage = UserPhoto(downloadurl: imageUrl, filename: imageFilename)
                    arrayOfUserImages.append(userImage)
                }
                }
            
            if arrayOfUserImages.count >= 1 {
                NotificationCenter.default.post(name: NSNotification.Name.init("FoundOtherPhotos"), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.init("NoPhotosFound"), object: nil)
            }
            
        }

    }
    static func fetchOtherPhotos() -> [UserPhoto] {
        return arrayOfUserImages
    }
    
    static func uploadMorePhotosForUser(userID:String, photoData:Data, photoIDString:String) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://eri-dating.appspot.com")
        
        
        let imageRef = storageRef.child("user_other_photos/\(userID)/\(photoIDString).jpg")
        
        let uploadTask:StorageUploadTask = imageRef.putData(photoData, metadata: nil) { (metadata, error) in
            if(error != nil) {
                print("Error: \(error!.localizedDescription)")
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "UploadComplete"), object: nil)
                
                let url = metadata?.downloadURL()

                self.addPhotoToUserDB(userUID: userID, pictureUrl: url!.absoluteString, pictureFilename: photoIDString)
            }
        }
        
        uploadTask.resume()
    }
    
    static func removeUserProfilePic(uid:String) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://eri-dating.appspot.com")
        
        let imgReference = "user_profile_pics/\(uid).jpg"
        let storageImageRef = storageRef.child(imgReference)
        
        storageImageRef.delete { (error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                self.removeProfileImageUrl(uid: uid)
            }
        }
    }
    static func removeProfileImageUrl(uid: String) {
        let ref = Database.database().reference().child("users").child(uid).child("profileimageurl")
        
        //let value = ["profileimageurl": profileImageUrl]
        
        ref.removeValue()
    }
    
    
    static func uploadUserProfilePicToServer(user:User, profileImage:Data) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://eri-dating.appspot.com")
        
        let userID = user.uid
        
        let imgName = "user_profile_pics/\(userID).jpg"
        let imageReference = storageRef.child(imgName)
        
        
        let uploadTask:StorageUploadTask = imageReference.putData(profileImage, metadata: nil, completion: { (storageMetaData, error) -> Void in
            if(error != nil) {
                print("Error: \(error!.localizedDescription)")
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "UploadComplete"), object: nil)
                
                let url = storageMetaData?.downloadURL()
                
                self.addProfileImageUrlTo(uid: userID, profileImageUrl: url!.absoluteString)
            }
        })
        uploadTask.resume()
    }
    
}
