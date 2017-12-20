//
//  ConnectedImage.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 19/06/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import FirebaseDatabase


enum ConnectionStatus {
    case Online
    case Offline
}
protocol ConnectedImageDelegate:class {
    func updateWithStatus(connectionStatus:ConnectionStatus)
}

class ConnectedImage:NSObject {
    private var startindex = 1
    
    var uid:String!
    var image:UIImage!
    var connectedUsersRef:DatabaseReference!
    var observingHandler:DatabaseHandle?
    
    var indexPath:IndexPath?
    
    weak var delegate:ConnectedImageDelegate?
    
    var connectionStatus:ConnectionStatus!
    {
        didSet {
            if connectionStatus == .Online {
                self.isOnline()
            } else if connectionStatus == .Offline {
                self.isOffline()
            }
        }
    }
    func getStatus() -> ConnectionStatus {
        if connectionStatus == .Online {
            return .Online
        } else {
            return .Offline
        }
    }
    
    init(userUID:String, indexpath:IndexPath) {
        super.init()
        
        self.indexPath = indexpath
        self.uid = userUID
        //self.image = UIImage(named: "red")
        
        self.connectionStatus = .Offline
        connectedUsersRef = Database.database().reference().child("connected_users")
        self.startindex = 0
        
        self.observeUser()
    }
    init(userUID:String) {
        super.init()

        self.uid = userUID
        self.connectionStatus = .Offline
        connectedUsersRef = Database.database().reference().child("connected_users")
        self.startindex = 0
        
        self.observeUser()
    }
    
    func isOffline() {
        if startindex == 1 {
            return
        }
        
        self.image = nil
        delegate?.updateWithStatus(connectionStatus: .Offline)
    }
    func isOnline() {
        if startindex == 1 {
            return
        }
        if let newimage = UIImage(named: "green") {
        self.image = newimage
        delegate?.updateWithStatus(connectionStatus: .Online)
        }
    }
    deinit {
        if let dbHandler = self.observingHandler {
            connectedUsersRef.removeObserver(withHandle: dbHandler)
        }
    }
    func observeUser() {
            if let uid = self.uid {
                self.observingHandler = connectedUsersRef.child(uid).observe(.value, with: { (snap) in
                    if let userStatus = snap.value as? Bool {
                        if userStatus == true {
                            self.connectionStatus = .Online
                        } else {
                            self.connectionStatus = .Offline
                        }
                    } else {
                        self.connectionStatus = .Offline
                    }
                    
                })
        } }
    
    
}
