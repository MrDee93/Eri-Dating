//
//  ProfileAboutTableViewCell.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 13/05/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit

class ProfileAboutTableViewCell: UITableViewCell {
    
    lazy var inputAccessoryViewOfTextArea: UIToolbar? = {
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
    
    var textView:UITextView?
    
    func createTextView() {
        textView?.isHidden = false
        textView?.textAlignment = NSTextAlignment.center
        textView?.font = UIFont.systemFont(ofSize: 17)
        textView?.spellCheckingType = .no
        textView?.autocorrectionType = .no
        textView?.text = "Write something about yourself here..."
        textView?.inputAccessoryView = self.inputAccessoryViewOfTextArea
    }
    override func awakeFromNib() {
        super.awakeFromNib()

        let newRect = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: 150)
        textView = UITextView(frame: newRect)
        
        
        if let textview = textView {
            createTextView()
            self.addSubview(textview)
            setConstraintsForView()
        }
    }
    
    func setConstraintsForView() {
        self.textView?.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.textView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.textView?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.textView?.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.textView?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
