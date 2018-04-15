//
//  EDUser.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 28/11/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import UIKit

final class EDUser: NSObject, Codable {
    
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
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case DOB = "dateofbirth"
        case about = "about"
        case id = "uid"
        case profilePicUrl = "profileimageurl"
        case country = "country"
        case city = "city"
        case gender = "gender"
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
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.name, forKey: .name)
        try container.encode(self.DOB, forKey: .DOB)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.country, forKey: .country)
        try container.encode(self.city, forKey: .city)
        try container.encode(self.profilePicUrl, forKey: .profilePicUrl)
        

        /*
        let dateofbirth = try values.decode(String.self, forKey: .DOB)
        self.DOB = dateofbirth
        
        let id = try values.decode(String.self, forKey: .id)
        self.id = id
        
        let country = try values.decode(String.self, forKey: .country)
        self.country = name
        
        
        let city = try values.decode(String.self, forKey: .city)
        self.city = city
        
        let profilepicurl = try values.decode(String.self, forKey: .profilePicUrl)
        self.profilePicUrl = profilepicurl*/
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try values.decode(String.self, forKey: .name)
        self.name = name
    
        let dateofbirth = try values.decode(String.self, forKey: .DOB)
        self.DOB = dateofbirth
        
        let id = try values.decode(String.self, forKey: .id)
        self.id = id
        
        let country = try values.decode(String.self, forKey: .country)
        self.country = name
    
        
        let city = try values.decode(String.self, forKey: .city)
        self.city = city
    
        let profilepicurl = try values.decode(String.self, forKey: .profilePicUrl)
        self.profilePicUrl = profilepicurl
    
        
        /*
        guard let quantity = try Int(values.decode(String.self, forKey: .quantity)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.quantity], debugDescription: "Expecting string representation of Int"))
        }
        self.quantity = quantity*/
    }
    
    
}






