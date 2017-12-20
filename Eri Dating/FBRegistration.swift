//
//  FBRegistration.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 28/11/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import Foundation

class FBRegistration {
    
    static func removeFBRegistration() {
        UserDefaults.standard.removeObject(forKey: "FBRegistrationProcess")
        UserDefaults.standard.removeObject(forKey: "FB-Name")
        UserDefaults.standard.removeObject(forKey: "FB-Gender")
        UserDefaults.standard.synchronize()
    }
    
    static func setFBRegistrationTrue() {
        UserDefaults.standard.set(true, forKey: "FBRegistrationProcess")
        UserDefaults.standard.synchronize()
    }
    static func setFBRegistrationFalse() {
        UserDefaults.standard.removeObject(forKey: "FBRegistrationProcess")
        UserDefaults.standard.synchronize()
    }
    
    static func checkFBData() -> Bool {
        if UserDefaults.standard.value(forKey: "FBRegistrationProcess") as? Bool == true {
            return true
        }
        return false
    }
    
    static func getFBName() -> String? {
        return UserDefaults.standard.value(forKey: "FB-Name") as? String
    }
    static func getFBGender() -> String? {
        let gender = UserDefaults.standard.value(forKey: "FB-Gender") as? String
        
        if gender == "Male" || gender == "male" {
            return "M"
        } else if gender == "Female" || gender == "female" {
            return "F"
        } else {
            //print("ERROR: Gender is ", gender)
            return nil
        }
    }
    
    static func getFBEmail() -> String? {
        return UserDefaults.standard.value(forKey: "FB-Email") as? String
    }
    
    
    
}


