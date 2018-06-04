//
//  UserDetailVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 29/11/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import UIKit

final class UserDetailVC: UIViewController, ConnectedImageDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var countOfExtraImageViews:Int = 1
    var connectedImage:ConnectedImage!
    var userConnectionStatus:UserConnectionStatus!
    
    @IBOutlet var userTableView:UITableView!
    @IBOutlet var userScrollView:UIScrollView!
    
    @IBOutlet var userProfileImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userLocationLabel: UILabel!
    
    // Connection status
    @IBOutlet var connectionStatusLabel:UILabel!
    
    @IBOutlet var connectionStatusImageView:UIImageView! {
        didSet {
            connectionStatusImageView.layer.cornerRadius = 10
            connectionStatusImageView.layer.masksToBounds = true
            connectionStatusImageView.contentMode = .scaleAspectFill
            connectionStatusImageView.isUserInteractionEnabled = false
        }
    }
    func checkSize() {
        let height = UIScreen.main.bounds.size.height
        if height < 500 {
            for constraint in self.userProfileImageView.constraints {
                if constraint.identifier == "widthConstraint" {
                    constraint.constant = 100
                }
            }
            for constraint in self.view.constraints {
                if constraint.identifier == "scrollViewSpaceConstraint" {
                    constraint.constant = 20
                }
            }
        }
        
    }
    
    func setupImageView(imageView: UIImageView) {
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleOpenPhotoView(_:))))
    }
    
    @objc func handleOpenPhotoView(_ sender:UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {
            let myStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let photoViewController = myStoryboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
            
            photoViewController.image = imageView.image
            photoViewController.uid = usersUID
            if let photoImageView = imageView as? UserPhotoImageView {
                photoViewController.imagename = photoImageView.fileName
            }
            self.present(photoViewController, animated: true, completion: nil)
            
        }
        
    }
    
    // Support for multiple photos of user
    @IBOutlet var otherPhotoOneImageView:UserPhotoImageView! {
        didSet {
            setupImageView(imageView: otherPhotoOneImageView)
        }
    }
    @IBOutlet var otherPhotoTwoImageView:UserPhotoImageView! {
        didSet {
            setupImageView(imageView: otherPhotoTwoImageView)
        }
    }
    @IBOutlet var otherPhotoThreeImageView:UserPhotoImageView! {
        didSet {
            setupImageView(imageView: otherPhotoThreeImageView)
        }
    }
    
    // Dynamically create ImageViews for Users photos
    func createImageView(xCoordinate: Int) -> UserPhotoImageView {
        let imageView = UserPhotoImageView(frame: CGRect.init(x: xCoordinate, y: 2, width: 100, height: 100))
        setupImageView(imageView: imageView)
        return imageView
    }
    
    // Handle zooming of images
    var customZoom:CustomImageZoom?
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            if imageView.image == UIImage(named: "noprofilepic") {
                return
            }
            customZoom = CustomImageZoom()
            
            let zoomingView:UIImageView = customZoom!.performZoomInForStartingImageView(startingImageView: imageView)
            zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut(tapGesture:))))
            zoomingView.isUserInteractionEnabled = true
        }
        
    }
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        customZoom?.handleZoomOut(tapGesture: tapGesture)
    }
    
    var userName:String?
    var userAge:Int?
    var usersUID:String?
    
    var user:EDUser? {
        didSet {
            if let name = user?.name {
                userName = name
            }
            if let DOB = user?.DOB {
                userAge = getAgeFor(dateOfBirth: DOB)
            }
            if let id = user?.id {
                usersUID = id
            }
        }
    }

    func updateWithStatus(connectionStatus: ConnectionStatus) {
        setConnectionStatus(connectionStatus: connectionStatus)
    }
    func setConnectionStatus(connectionStatus:ConnectionStatus) {
        if connectionStatus == .Offline {
            connectionStatusLabel.text = "Offline"
            connectionStatusImageView.image = UIImage(named: "red")
        } else if connectionStatus == .Online {
            connectionStatusLabel.text = "Online"
            connectionStatusImageView.image = UIImage(named: "green")
        }
    }
    
    // FIXME
    override func viewDidLoad() {
        super.viewDidLoad()
        if userName != nil {
            self.navigationItem.title = "\(userName!)"
        } else {
            print("ERROR: No such user.")
            return
        }
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "...", style: .plain, target: self, action: #selector(moreOptions))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 20)], for: .normal)
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeMessage))
        
        self.userConnectionStatus = UserConnectionStatus(userUID: self.usersUID!)
        self.userConnectionStatus.delegate = self
        
        setUserDetails()
        setUpProfilePic()
        checkIfUserIsBlocked()
        
        checkSize()
    }
    func checkIfUserIsBlocked() {
        UserBlocker.isUserOnBlockedList(blockedUserUID: usersUID!, vc: self)

    }
    var isUserBlocked:Bool?
    
  
    @objc func moreOptions() {
        let options = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        options.addAction(UIAlertAction(title: "Report User", style: .destructive, handler: { (action) in
            self.reportUser()
        }))
        if isUserBlocked != nil && isUserBlocked == true {
            options.addAction(UIAlertAction(title: "Unblock User", style: .destructive, handler: { (action) in
                self.unblockUser()
            }))
        } else {
        options.addAction(UIAlertAction(title: "Block User", style: .destructive, handler: { (action) in
            self.blockUser()
        }))
        }
        options.addAction(UIAlertAction(title: "Send Message", style: .default, handler: { (action) in
            self.composeMessage()
        }))
        
        options.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(options, animated: true, completion: nil)
        
    }
    func reportUser() {
        self.present(ReportingFacility.reportUser(id: usersUID!), animated: true, completion: nil)
    }
    func blockUser() {
        isUserBlocked = true
        UserBlocker.blockUser(blockedUserUID: usersUID!)
    }
    func unblockUser() {
        isUserBlocked = false
        UserBlocker.unblockUser(blockedUserUID: usersUID!)
    }
    
    func setUserDetails() {
        if let username = userName, let userage = userAge {
            if let gender = user?.gender {
                self.userNameLabel.text = "\(username), \(gender), \(userage)"
            } else {
                self.userNameLabel.text = "\(username), \(userage)"
            }
        }
        
        
        if let usercountry = user?.country {
            if let usercity = user?.city {
                self.userLocationLabel.text = "\(usercity), \(usercountry)"
            } else {
                self.userLocationLabel.text = "\(usercountry)"
            }
        }
        
        Users.getPhotosForUser(userUID: usersUID!)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedOtherPhotos), name: NSNotification.Name.init("FoundOtherPhotos"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(foundNoPhotos), name: NSNotification.Name.init("NoPhotosFound"), object: nil)
    }
    
    @objc func foundNoPhotos() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("FoundOtherPhotos"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("NoPhotosFound"), object: nil)
    }
    
    @objc func receivedOtherPhotos() {
        let photos = Users.fetchOtherPhotos()
        
            for userImage in photos {
                if self.otherPhotoOneImageView.image == UIImage(named: "noprofilepic") {
                    self.otherPhotoOneImageView.loadImageUsingCacheWithUrlString(urlString: userImage.downloadUrl)
                    self.otherPhotoOneImageView.fileName = userImage.fileName
                } else if self.otherPhotoTwoImageView.image == UIImage(named: "noprofilepic") {
                    self.otherPhotoTwoImageView.loadImageUsingCacheWithUrlString(urlString: userImage.downloadUrl)
                    self.otherPhotoTwoImageView.fileName = userImage.fileName
                } else if self.otherPhotoThreeImageView.image == UIImage(named: "noprofilepic") {
                    self.otherPhotoThreeImageView.loadImageUsingCacheWithUrlString(urlString: userImage.downloadUrl)
                    self.otherPhotoThreeImageView.fileName = userImage.fileName
                } else {
                    var xCoord:Int
                    let extraX = 120*countOfExtraImageViews
                    let extraWidth = 150 * countOfExtraImageViews
                    
                    xCoord = 257+extraX
                    let imageView = createImageView(xCoordinate: xCoord)
                    
                    self.userScrollView.addSubview(imageView)
                    
                    imageView.loadImageUsingCacheWithUrlString(urlString: userImage.downloadUrl)
                    imageView.fileName = userImage.fileName
                    countOfExtraImageViews = countOfExtraImageViews + 1

                    let newSize = CGSize(width: 400 + CGFloat(extraWidth), height: self.userScrollView.frame.height)
                    
                    self.userScrollView.contentSize = newSize
                }
            }
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("FoundOtherPhotos"), object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("NoPhotosFound"), object: nil)
    }
    
    @objc func composeMessage() {
        let chatLogController = ChatLogControllerCVC(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        self.navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func setUpProfilePic() {
        if let profileImageUrl = self.user?.profilePicUrl {
            userProfileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            setupImageView(imageView: userProfileImageView)
        } else {
            self.userProfileImageView.image = UIImage(named: "noprofilepic")
        }
    }
    
    func setUser(user:EDUser) {
        self.user = user
    }
    
    func calculateAge(dateOfBirth: Date) -> Int {
        var age:Int = 10
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        let timeInterval = dateOfBirth.timeIntervalSinceNow * -1
        age = Int(Double(timeInterval) * 3.171e-8)
        
        return age
    }
    
    func getAgeFor(dateOfBirth:String) -> Int {
        let dateOfBirthDate = DateFormat.getDateFromString(string: dateOfBirth)
        let age = calculateAge(dateOfBirth: dateOfBirthDate)
        return age
    }
    
    func setupUserAboutTableView(cell:ProfileAboutTableViewCell) -> ProfileAboutTableViewCell {
        cell.textView?.isEditable = false
        cell.textView?.isUserInteractionEnabled = false
        if let userAboutMe = user?.about {
            cell.textView?.text = userAboutMe
        } else {
            cell.textView?.text = "No user info found"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath) as! ProfileAboutTableViewCell
            /*
            cell.textView?.isEditable = false
            cell.textView?.isUserInteractionEnabled = false
            if let userAboutMe = user?.about {
                cell.textView?.text = userAboutMe
            } else {
                cell.textView?.text = "No user info found"
            }
            
            return cell*/
            return setupUserAboutTableView(cell: cell)
            
        } else {
            let row = indexPath.row
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! ProfileTableViewCell
            
            /*
            switch(row) {
            case 0:
                cell.textField?.placeholder = "Relationship Status"
                
                if let userRelationshipStatus = user?.relationship_status {
                    cell.textField?.text = userRelationshipStatus
                }
            case 1:
                cell.textField?.placeholder = "Looking For"
                if let userLookingFor = user?.looking_for {
                    cell.textField?.text = userLookingFor
                }
            default:
                print("Default reached!")
                break
            }*/
            return setupTableViewCell(row: row, cell: cell)
            //return cell
            
        }
    }
    func setupTableViewCell(row:Int, cell: ProfileTableViewCell) -> ProfileTableViewCell  {
        cell.textField?.isUserInteractionEnabled = false
        switch(row) {
        case 0:
            cell.textField?.placeholder = "Relationship Status"
            
            if let userRelationshipStatus = user?.relationship_status {
                cell.textField?.text = userRelationshipStatus
            }
        case 1:
            cell.textField?.placeholder = "Looking For"
            if let userLookingFor = user?.looking_for {
                cell.textField?.text = userLookingFor
            }
        default:
            break
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "About:"
        } else {
            return "Bio:"
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 150
        }
        else {
            return 45
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }

}
