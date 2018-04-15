//
//  MessagesTVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 12/12/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import Firebase
import UIKit
import AVFoundation

final class MessagesTVC: UITableViewController {

    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    var totalNewMessages:Int? = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        clearBadge()
        
        attemptReloadOfTable()
        self.timer?.invalidate()
        self.timer = Timer(timeInterval: 0.30, target: self, selector: #selector(handleReloadTable), userInfo: nil, repeats: false)
    }
    func clearBadge() {
        self.navigationController?.tabBarItem.badgeValue = nil
        totalNewMessages = 0
    }
    func vibrateForMessage() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    func increaseBadge() {
        if let totalmessages = totalNewMessages {
            totalNewMessages = totalmessages + 1
        print(totalmessages)
        self.navigationController?.tabBarItem.badgeValue = "\(totalNewMessages!)"
        }
    }

    
    func newMessage() {
        increaseBadge()
        vibrateForMessage()
    }
    /*
    override func loadView() {
        super.loadView()
        
        // TESTING
        loadTheView()
        print("Loading VIEW")
    }*/
    func loadTheView() {
        self.navigationController?.tabBarItem.badgeColor = UIColor.getBlue()
        tableView.register(UserCell.self, forCellReuseIdentifier: "messagesCell")
        
        removeAndReloadData()
        fetchUserAndSetupNavBarTitle()
        tableView.allowsSelectionDuringEditing = true
        

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTheView()
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let message = self.messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerId() {
            let messagesRef = Database.database().reference().child("messages")
            let ref = Database.database().reference().child("user-messages").child(uid).child(chatPartnerId)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children.allObjects {
                    let theChild = child as! DataSnapshot
                    messagesRef.child(theChild.key).removeValue()
                }
            })
            
            
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, databaseref) in
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                DispatchQueue.main.async {
                    self.messagesDictionary.removeValue(forKey: chatPartnerId)
                    self.attemptReloadOfTable()
                }
            })
            Database.database().reference().child("user-messages").child(chatPartnerId).child(uid).removeValue(completionBlock: { (error, databaseref) in
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                DispatchQueue.main.async {
                    self.messagesDictionary.removeValue(forKey: chatPartnerId)
                    self.attemptReloadOfTable()
                }
            })
        }
    }
    func removeAndReloadData() {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                    let messageId = snapshot.key
                
                    self.fetchMessageWithMessageId(messageId: messageId)

                 })
            }, withCancel: nil)
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }, withCancel: nil)
        
    }
    
    private func fetchMessageWithMessageId(messageId: String) {
        let messageReference = Database.database().reference().child("messages").child(messageId)
        
        // Observing keeps database updated compared to SingleEvent method
        messageReference.observe(.value, with: { (snapshot) in
        //messageReference.observeSingleEvent(of: .value, with: { (snapshot) in -
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                message.messageId = snapshot.key
                //print("ID: \(snapshot.key) - newmessage: ", message.newmessage?.intValue)
                //message.setValuesForKeys(dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    if(self.checkIfMessageIsNew(message: message)) {
                        self.newMessage()
                    } else {
                    }
                }
                self.attemptReloadOfTable()
            }
        }, withCancel:nil)
    }
    
    private func attemptReloadOfTable() {
        self.messages = Array(self.messagesDictionary.values)

        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer:Timer?
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    
    func fetchUserAndSetupNavBarTitle() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        guard let uid = appDelegate.FirebaseAuth.currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                guard let imageUrl = dictionary["profileimageurl"] else {
                    if let name = dictionary["name"] as? String {
                        DispatchQueue.main.async(execute: {
                            self.setupNavBarWith(name: name)
                        })
                    } else {
                        if let fbName = FBRegistration.getFBName() {
                            DispatchQueue.main.async(execute: {
                                self.setupNavBarWith(name: fbName)
                            })
                        } else {
                            print("ERROR: No name found from Facebook (MessagesTVC).")
                        }
                        
                    }
                    
                    return
                }
                
                //if let imageUrl = dictionary["profileimageurl"] as! String {
                    let name = dictionary["name"] as! String
                    DispatchQueue.main.async(execute: {
                        self.setupNavBarWith(name: name, profileImageUrl: imageUrl as! String)
                    })
            }
        }, withCancel: nil)
    }

    
    func getWidth(title:String) -> CGFloat {
        let size = CGSize.init(width: 200, height: 40)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        var estimatedRect:CGRect = CGRect.zero
        
        if title.count > 12 {
            let index = title.index(title.startIndex, offsetBy: 12)
            let newTitle = String(title.prefix(upTo: index))
            estimatedRect = NSString(string: newTitle).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)], context: nil)
        } else {
            estimatedRect = NSString(string: title).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)], context: nil)
        }
        
        return estimatedRect.width + 5
    }
    func setupNavBarWith(name: String) {
        var xValue = 0
        
        let profileImageViewOriginX = getWidth(title: name)
        if(name.count < 6) {
            xValue += (50 - name.count)
        } else {
            xValue += (20 - name.count)
        }
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        titleView.isHidden = false
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        //containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isHidden = false
        
        let profileImageView = UIImageView(frame: CGRect(x: CGFloat(xValue) + profileImageViewOriginX + 5, y: 0, width: 40, height: 40))
        
        //profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.isHidden = false
        
        profileImageView.image = UIImage(named: "noprofilepic")
        
        containerView.addSubview(profileImageView)
        titleView.addSubview(containerView)
        
        let nameLabel = UILabel(frame: CGRect(x: xValue, y: 0, width: 120, height: 40))
        
        nameLabel.text = name
        //nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = UIColor.getRed()
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        containerView.addSubview(nameLabel)
        
        self.navigationItem.titleView = titleView
        
        NavigationBar.setColourSchemeFor(navBar: (self.navigationController?.navigationBar)!)
        
        observeUserMessages()
    }
    func setupNavBarWith(name: String, profileImageUrl: String) {
        var xValue = 0
        
        let profileImageViewOriginX = getWidth(title: name)
        if(name.count < 6) {
            xValue += (50 - name.count)
        } else {
            xValue += (20 - name.count)
        }

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        
        //titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.isHidden = false
        

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        //containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isHidden = false
        
        let profileImageView = UIImageView(frame: CGRect(x: CGFloat(xValue) + profileImageViewOriginX + 5, y: 0, width: 40, height: 40))
        
        //profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.isHidden = false
        
        profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        
        
        containerView.addSubview(profileImageView)
        titleView.addSubview(containerView)

        let nameLabel = UILabel(frame: CGRect(x: xValue, y: 0, width: 120, height: 40))
        
        nameLabel.text = name
        //nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = UIColor.getRed()
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))

        containerView.addSubview(nameLabel)
        
        
        self.navigationItem.titleView = titleView
        
        //titleView.centerXAnchor.constraint(equalTo: (self.navigationItem.titleView?.centerXAnchor)!).isActive = true
        if let navBar = self.navigationController?.navigationBar {
            NavigationBar.setColourSchemeFor(navBar: navBar)
        }
        observeUserMessages()
    }
    @objc func handleTap() {
        self.navigationController?.tabBarController?.selectedIndex = 2
    }
    func createMessage() {
        let chatLogController = ChatLogControllerCVC(collectionViewLayout: UICollectionViewFlowLayout())

        self.navigationController?.pushViewController(chatLogController, animated: true)
    }
    func showChatControllerForUser(user: EDUser) {
        let chatLogController = ChatLogControllerCVC(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        self.navigationController?.pushViewController(chatLogController, animated: true)
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    
    func checkIfMessageIsNew(message:Message) -> Bool {
        if let toId = message.toId {
            guard let uid = Auth.auth().currentUser?.uid else {
                return false
            }
            if toId == uid {
                if let newmessage = message.newmessage?.intValue {
                    if newmessage == 1 {
                        return true
                    } else if newmessage == 0 {
                        return false
                    }
                }
            }
            
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "messagesCell", for: indexPath) as! UserCell

        let message = messages[indexPath.row]

        cell.message = message
        
        /*
        if(checkIfMessageIsNew(message: message)) {
            DispatchQueue.main.async(execute: { 
                cell.newMessage = UIImageView(image: UIImage(named: "newmessage"))
                print("(CELL) NEW MESSAGE:", message)
            })
        } else {
            cell.newMessage = nil
        }*/
        
        if(checkIfMessageIsNew(message: message)) {
            cell.newMessage?.isHidden = false
            newMessage()
        } else {
            cell.newMessage?.isHidden = true
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        let userCell = tableView.cellForRow(at: indexPath) as? UserCell
        userCell?.newMessage?.isHidden = true
        
        self.messagesDictionary[chatPartnerId]?.newmessage = NSNumber(integerLiteral: 0)
        // Update the Message as no longer new.
        // HERE:
        /*
        if let messageID = message.messageId {
            print("DID SELECT")
            //openedNewMessage(messageId: messageID)
        }*/
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {
                return
            }
            
            let user:EDUser
            //if let name = dictionary["name"], let id = dictionary["uid"], let country = dictionary["country"], let dob = dictionary["dateofbirth"], let profileImageUrl = dictionary["profileimageurl"] {
                // TEMPORARY
                //user.setUser(name: name as! String, id: id as! String, profileImageUrl: profileImageUrl as! String, DOB: dob as! String, country: country as! String)
                user = EDUser(dictionary: dictionary)
                self.showChatControllerForUser(user: user)
            //} else {
            //    print("ERROR. Unable to create User object")
            //}
 
        }, withCancel: nil)
    }
    func openedNewMessage(messageId:String) {
        let userMessageReference = Database.database().reference().child("messages").child(messageId)
        
        
        userMessageReference.updateChildValues(["newmessage":0])
    }

}
