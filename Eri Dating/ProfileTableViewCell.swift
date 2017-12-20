//
//  ProfileTableViewCell.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 12/05/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    lazy var textField:UITextField? = {
        var textfield:UITextField = UITextField(frame: self.frame)
        textfield.isHidden = false
        textfield.textAlignment = NSTextAlignment.center
        textfield.autocorrectionType = .no
        textfield.spellCheckingType = .no
        textfield.inputAccessoryView = self.inputAccessoryViewOfTextField
        return textfield
    }()
    
    lazy var inputAccessoryViewOfTextField: UIToolbar? = {
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        
        let flexiSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButtonDone = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        
        toolbarDone.items = [flexiSpace, barButtonDone]
        
        return toolbarDone
    }()
    
    @objc func handleDone() {
        self.endEditing(true)
    }
    override func prepareForReuse() {
        self.textField?.text = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        if let textfield = textField {
            self.addSubview(textfield)
            addConstraintForField()
        }
    }
    
    func addConstraintForField() {
        self.textField?.translatesAutoresizingMaskIntoConstraints = false
        
        self.textField?.leftAnchor.constraint(equalTo: (self.leftAnchor)).isActive = true
        self.textField?.rightAnchor.constraint(equalTo: (self.rightAnchor)).isActive = true
        
        //self.textField?.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        //self.textField?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
        
        self.textField?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.textField?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
