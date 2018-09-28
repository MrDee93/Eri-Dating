//
//  FiltersTVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 28/09/2018.
//  Copyright © 2018 Dayan Yonnatan. All rights reserved.
//

import UIKit

class FiltersTVC: UITableViewCell {

	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .default, reuseIdentifier: "FilterCell")
		
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		print("Awake from nib")
		if let textfield = textField {
			//self.addSubview(textfield)
			//addConstraintForField()
		}
	}
	lazy var textField:UITextField? = {
		var textfield:UITextField = UITextField(frame: self.frame)
		textfield.isHidden = false
		textfield.textAlignment = NSTextAlignment.center
		textfield.autocorrectionType = .no
		textfield.spellCheckingType = .no
		textfield.inputAccessoryView = self.inputAccessoryViewOfTextField
		return textfield
	}()
	
	func addConstraintForField() {
		self.textField?.translatesAutoresizingMaskIntoConstraints = false
		
		self.textField?.leftAnchor.constraint(equalTo: (self.leftAnchor)).isActive = true
		self.textField?.rightAnchor.constraint(equalTo: (self.rightAnchor)).isActive = true
		
		self.textField?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		self.textField?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}
	


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	override func prepareForReuse() {
		self.textField?.text = nil
	}
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
}
