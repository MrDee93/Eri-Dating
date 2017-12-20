//
//  TextController.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 13/05/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit


class TextController: NSObject, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var oldString:String?
    var userUID:String?
    
    init(useruid:String) {
        self.userUID = useruid
    }
    override init() {
        super.init()
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.oldString = textField.text
    }

    func isTextFieldEmpty(_ text:String) -> Bool {
        if (text == "") || (text.isEmpty) {
            return true
        }
        return false
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        let placeholderText = "Write something about yourself here..."
        if let textViewText = textView.text {
            if (textViewText.compare(placeholderText) == ComparisonResult.orderedSame) {
                textView.text = ""
            }
        }
    }
    
   
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(isTextFieldEmpty(textField.text!)) {
            print("ERROR: Empty textfield.")
            if let previousString = self.oldString {
                textField.text = previousString
            }
            return
        }
        if textField.tag == 120 {
            // Relationship status
            if let useruid = self.userUID {
                guard let textfieldtext = textField.text else {
                    return
                }
                Users.updateRelationshipStatus(userUID: useruid, newStatus: textfieldtext)
            }
        } else if textField.tag == 115 {
            // Looking for
            if let useruid = self.userUID {
                guard let textfieldtext = textField.text else {
                    return
                }
                Users.updateLookingFor(userUID: useruid, newLookingFor: textfieldtext)
            }
        } else if textField.tag == 128 {
            if let newName = textField.text {
                if let useruid = self.userUID {
                    Users.updateUserName(UID: useruid, Name: newName)
                }
            }
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        let placeholderText = "Write something about yourself here..."
        
        if let textViewText = textView.text {
            if(textViewText == "" || textViewText.isEmpty || textViewText == " " || textViewText == "\n") {
                textView.text = placeholderText
                if let useruid = self.userUID {
                    Users.updateUserAboutInfo(UID: useruid, About: "")
                }
                return
            }
        }
        
        if let newTextViewText = textView.text {
            if let useruid = self.userUID {
                Users.updateUserAboutInfo(UID: useruid, About: newTextViewText)
            }
        }
        
    }
    var relationshipStatusTextField:UITextField?
    var lookingForTextField:UITextField?
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 354 {
            if let relationshipfield = relationshipStatusTextField {
                relationshipfield.text = returnRelationshipStatusOptions()[row]
            }
        } else {
            if let lookingfield = lookingForTextField {
                lookingfield.text = returnLookingForOptions()[row]
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 354 {
            return 6
        }
        return 3
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 354 {
           return returnRelationshipStatusOptions()[row]
        } else {
           return returnLookingForOptions()[row]
        }
    }
    func returnRelationshipStatusOptions() -> [String] {
        return ["Single", "In a relationship", "Complicated", "Married", "Engaged", "Divorced"]
    }
    
    func returnLookingForOptions() -> [String] {
        return ["Looking for a Chat", "Looking for a Relationship", "Looking for Friendship"]
    }
    
    
}


