//
//  EDUser.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 28/11/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import UIKit

class EDUser: NSObject {

    var name:String?
    var DOB:String?
    var country:String?
    var city:String?
    var profilePic:UIImage?
    var id:String?
    var gender:String?
    
    // For Brians methods
    var profilePicUrl:String?
    
    var about:String?
    var relationship_status:String?
    var looking_for:String?
    
    override init() {
        super.init()
        
    }
    init(User userD:EDUser) {
        super.init()
        
        if let usersname = userD.name {
            self.name = usersname
        }
        if let dateofbirth = userD.DOB {
            self.DOB = dateofbirth
        }
        if let about = userD.about {
            self.about = about
        }
        if let userscountry = userD.country {
            self.country = userscountry
        }
        if let userscity = userD.city {
            self.city = userscity
        }
        if let relationshipstatus = userD.relationship_status {
            self.relationship_status = relationshipstatus
        }
        if let lookingfor = userD.looking_for {
            self.looking_for = lookingfor
        }
        if let gender = userD.gender {
            self.gender = gender
        }
        
    }
    
    init(dictionary: Dictionary<String, Any>) {
        super.init()
        
        if let usersName = dictionary["name"] as? String {
            self.name = usersName
        }
        if let usersDOB = dictionary["dateofbirth"] as? String {
            self.DOB = usersDOB
        }
        if let usersAbout = dictionary["about"] as? String {
            self.about = usersAbout
        }
        //if let name = dictionary["name"], let id = dictionary["uid"], let country = dictionary["country"], let dob = dictionary["dateofbirth"], let profileImageUrl = dictionary["profileimageurl"] {
        if let usersId = dictionary["uid"] as? String {
            self.id = usersId
        }
        if let profileImageUrl = dictionary["profileimageurl"] as? String {
            self.profilePicUrl = profileImageUrl
        }
        if let userscountry = dictionary["country"] as? String {
            self.country = userscountry
        }
        
        if let userscity = dictionary["city"] as? String {
            self.city = userscity
        }
        if let usersgender = dictionary["gender"] as? String {
            self.gender = usersgender
        }
    }
    
    func set(name:String, DOB:String, country:String, profilePic:UIImage) {
        self.name = name
        self.DOB = DOB
        self.country = country
        self.profilePic = profilePic
    }
    func setUser(name: String, id:String, profileImageUrl: String, DOB:String, country:String) {
        self.name = name
        self.id = id
        self.profilePicUrl = profileImageUrl
        self.DOB = DOB
        self.country = country
    }
    
}
