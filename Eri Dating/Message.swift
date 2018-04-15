//
//  Messages.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 12/12/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//
import UIKit
import Firebase

class Message: NSObject {
    
    var text:String?
    var fromId:String?
    var toId:String?
    var timestamp:NSNumber?
    
    
    // for sending images
    var imageUrl:String?
    var imageHeight:NSNumber?
    var imageWidth:NSNumber?
    
    // for videos
    var videoUrl:String?
    
    // for unread/read messages
    var newmessage:NSNumber?
    
    
    var messageId:String?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    
    init(dictionary: [String : Any]) {
        super.init()
        
        
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        toId = dictionary["toId"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        
        
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        
        videoUrl = dictionary["videoUrl"] as? String
        
        newmessage = dictionary["newmessage"] as? NSNumber
        
    }
}
