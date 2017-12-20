//
//  UserCell.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 01/03/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
            
           /* if let newmessageInt = message?.newmessage?.intValue {
                if newmessageInt == 1 {
                            newMessage?.layer.cornerRadius = 7
                            newMessage?.layer.masksToBounds = true
                            newMessage?.contentMode = .scaleAspectFill
                            newMessage?.translatesAutoresizingMaskIntoConstraints = false
                            setupNewMessageView()
                }
            }*/
        }
    }
    
    private func setupNameAndProfileImage() {
        if let id = message?.chatPartnerId() {

            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileimageurl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // TEMPORARY EDIT
        /*
        textLabel?.frame = CGRect.init(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect.init(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)*/
        textLabel?.frame = CGRect.init(x: 84, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect.init(x: 84, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
        
        
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel:UILabel = {
       let label = UILabel()
        //label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    var newMessage: UIImageView?
        /*
         didSet {
         if(newMessage != nil) {
     
         setupNewMessageView()
         }
         }
         */
    
    var profileImageViewLeftAnchor:NSLayoutConstraint?
    
    
    func setupNewMessageView() {
        newMessage = UIImageView(image: UIImage(named: "newmessage"))
        newMessage?.layer.cornerRadius = 7
        newMessage?.layer.masksToBounds = true
        newMessage?.contentMode = .scaleAspectFill
        newMessage?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(newMessage!)
        newMessage?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        newMessage?.heightAnchor.constraint(equalToConstant: 15).isActive = true
        newMessage?.widthAnchor.constraint(equalToConstant: 15).isActive = true
        newMessage?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    
    
    override func prepareForReuse() {
        newMessage?.isHidden = true
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors

        profileImageViewLeftAnchor = profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 28)
        
        profileImageViewLeftAnchor?.isActive = true
        
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        setupNewMessageView()
        newMessage?.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
