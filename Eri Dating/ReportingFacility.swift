//
//  ReportingFacility.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 12/12/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ReportingFacility {
    
    
    static func reportUser(id:String) -> UIAlertController {
        let alert = UIAlertController(title: "Report User", message: "Reason for Report:", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .destructive, handler: { (action) in
            if alert.textFields?.last?.text == "" || alert.textFields?.last?.text == nil {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let alert = UIAlertController(title: "ERROR", message: "You must specify a reason for reporting this user.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
                appDelegate.presentCustom(viewController: alert)
            } else {
                self.completeUserReport(id: id, comments: alert.textFields?.last?.text)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        return alert
    }
    
    static func reportPhoto(id:String, filename:String?) -> UIAlertController {
        let alert = UIAlertController(title: "Report Photo", message: "State the reason why you find this image inappropriate (optional)", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .destructive, handler: { (action) in
            self.completePhotoReport(id: id, filename: filename, comments: alert.textFields?.last?.text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        return alert
    }
    static func completePhotoReport(id:String, filename:String?, comments:String?) {
        var values = [String:String]()
        
        values.updateValue("Photo", forKey: "reportType")
        
        if filename != nil {
            values.updateValue(filename!, forKey: "photoFilename")
        } else {
            values.updateValue("Profile", forKey: "photoFilename")
        }
        
        if comments != nil {
            values.updateValue(comments!, forKey: "comments")
        }
        values.updateValue(id, forKey: "uid")
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = self.getDateFormat()
        let currentTimeAndDay = Date.init()
        
        values.updateValue(dateFormat.string(from: currentTimeAndDay), forKey: "timestamp")
        
        self.addReport(values: values)
        
       // thankUserForReporting()
    }
    static func completeUserReport(id:String, comments:String?) {
        var values = [String:String]()
        
        values.updateValue("User", forKey: "reportType")
        
        if comments != nil {
            values.updateValue(comments!, forKey: "comments")
        }
        values.updateValue(id, forKey: "uid")
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = self.getDateFormat()
        let currentTimeAndDay = Date.init()
        
        values.updateValue(dateFormat.string(from: currentTimeAndDay), forKey: "timestamp")
        
        self.addReport(values: values)
       // thankUserForReporting()
    }
    
    static func thankUserForReporting() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let alert = UIAlertController(title: "Thank You", message: "Thank you for reporting content.\nWe take all reports seriously and we will investigate immediately.\nYou will remain anonymous.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
        
        appDelegate.presentCustom(viewController: alert)
    }
    
    
    static func getDateFormat() -> String {
        return "HH:mm:ss dd/MM/yy"
    }
    
    
    
    static func addReport(values:[String:String]) {
        let reportRef = Database.database().reference().child("Reports").childByAutoId()
        
        // Timestamp
        // UID of reported photo
        // Comments (optional)
        
        // Create Firebase Function to receive notifications to all admins whenever a new report is published on the database
        
       // let timestamp = Date.init()
        
        //print("Added report at: ", dateFormat.string(from: timestamp))
        
        /*
        let values = ["comment":"A comment",
                      "timestamp":dateFormat.string(from: timestamp),
                      "photofilename":"photo Name",
                      "uid":"owner of photo uid"
        ]
        */

        reportRef.updateChildValues(values)
        thankUserForReporting()
    }
    

    
}
