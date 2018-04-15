//
//  UserBlocker.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 12/12/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserBlocker {
    
    static func getRegisteredUID() -> String? {
       return (UIApplication.shared.delegate as? AppDelegate)?.activeUser.uid
    }
    static func blockUser(blockedUserUID:String) {
        if let uid = getRegisteredUID() {
        let ref = Database.database().reference().child("blocked_list").child(uid)
        
        let blockedUser = [blockedUserUID:true]
        
        ref.updateChildValues(blockedUser)
        }
    }
    
    static func unblockUser(blockedUserUID:String) {
        if let uid = getRegisteredUID() {
            let ref = Database.database().reference().child("blocked_list").child(uid).child(blockedUserUID)
            
            ref.removeValue()
            
        }
    }
    
    static func amIBlocked(targetUID:String, chatLogVC:ChatLogControllerCVC) {
        if let uid = getRegisteredUID() {
            
            let ref = Database.database().reference().child("blocked_list").child(targetUID)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snappeduid = snapshot.value as? NSDictionary {
                    snappeduid.enumerateKeysAndObjects({ (key, object, stopPointer) in
                        if let keyString = key as? String {
                            
                            if keyString.compare(uid) == ComparisonResult.orderedSame {
                                // I AM BLOCKED!
                                print("User is blocked.")
                                chatLogVC.disableSendingMessages()
                            }
                        }
                    })
                }
            })
        }
    }
    static func isUserOnBlockedList(blockedUserUID:String, vc:UserDetailVC) {
        var foundUser:Bool?
        if let uid = getRegisteredUID() {
            
        let ref = Database.database().reference().child("blocked_list").child(uid)
        
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snappeduid = snapshot.value as? NSDictionary {
                    snappeduid.enumerateKeysAndObjects({ (key, object, stopPointer) in
                        if let keyString = key as? String {
                            
                       if keyString.compare(blockedUserUID) == ComparisonResult.orderedSame {
                            vc.isUserBlocked = true
                            foundUser = true
                            print("User is blocked.")
                        }
                        }
                    })
                }
            })
            if(foundUser == nil || foundUser == false) {
                vc.isUserBlocked = false
            }
        }
    }
    
}
