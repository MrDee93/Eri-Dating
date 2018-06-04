//
//  MyProfileVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 16/12/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

final class MyProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UpdateUserLocationDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet var myProfileScrollView:UIScrollView!
    
    var countries:[String]?
    @IBOutlet var tableView:UITableView?
    @IBOutlet var addMorePhotosImageView:UserPhotoImageView! {
        didSet {
            setupImageView(imageView: addMorePhotosImageView)
            addMorePhotosImageView.addGestureRecognizer(createTapGestureForAddPhotos())
        }
    }
    @IBOutlet var otherPhotoOneImageView:UserPhotoImageView! {
        didSet {
            setupImageView(imageView: otherPhotoOneImageView)
            otherPhotoOneImageView.addGestureRecognizer(createTapGestureForZoomIn())
            
        }
    }
    @IBOutlet var otherPhotoTwoImageView:UserPhotoImageView! {
        didSet {
            setupImageView(imageView: otherPhotoTwoImageView)
            otherPhotoTwoImageView.addGestureRecognizer(createTapGestureForZoomIn())
            
        }
    }
    @IBOutlet var otherPhotoThreeImageView:UserPhotoImageView! {
        didSet {
            setupImageView(imageView: otherPhotoThreeImageView)
            otherPhotoThreeImageView.addGestureRecognizer(createTapGestureForZoomIn())
        }
    }
    func setupImageView(imageView: UIImageView) {
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
    }
    
    func checkSize() {
        let width = UIScreen.main.bounds.size.width
        
        for constraint in self.userScrollView.constraints {
            if constraint.identifier == "userScrollViewWidth" {
                constraint.constant = width
            }
        }
    }
    
    var loadingView:LoadingView?
    var loadedUserDetails:Bool = false
    
    var appDelegate:AppDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    
    var textController:TextController = {
        var textController = TextController()
        return textController
    }()
    
    @IBOutlet var profilePicImageView: UIImageView! {
        didSet {
            setupImageView(imageView: profilePicImageView)
            profilePicImageView.addGestureRecognizer(createTapGestureForProfilePic())
        }
    }
    
    var profilePicture:UIImage! {
        didSet {
            if loadedUserDetails == false {
                loadUserDetails()
                loadedUserDetails = true
            }
        }
    }
    var user:EDUser? {
        didSet {
            self.reloadTable()
        }
    }
    func stopLoading() {
        if let loadingView = self.loadingView {
            loadingView.stopLoading()
            self.loadingView = nil
        }
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.reloadTable()
        
        myProfileScrollView.translatesAutoresizingMaskIntoConstraints = false
        myProfileScrollView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        
    }
    func checkForProfilePic() {
        if let id = self.user?.id {
            ProfilePhotoChecker.checkIfUserHasProfilePhoto(id)
        }
    }
    
    func checkAndDisplayTutorial() {
        if let showTutorial = UserDefaults.standard.value(forKey: "ShowTutorial") as? Bool {
            if showTutorial == true {
                // Show tutorial
                let alert = UIAlertController(title: "Your Profile", message: "This is your Profile.\nYou need to enter some information about yourself\nFirst, select a profile picture.", preferredStyle: .alert)
                let addPhoto = UIAlertAction(title: "Add profile picture", style: .default, handler: { (action) in
                    self.addProfilePicture()
                })
                let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                
                alert.addAction(addPhoto)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
                UserDefaults.standard.removeObject(forKey: "ShowTutorial")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    @objc func openPhotoView(taprecognizer: UITapGestureRecognizer) {
        if let imageView = taprecognizer.view as? UserPhotoImageView {
            if imageView.image == UIImage(named: "noprofilepic") {
                return
            }
            createDeletePhotoListener()
            
            
            if let fileName = imageView.fileName {
                selectedUserImageView = imageView
                selectedUserImageView?.fileName = fileName
            }
            
            let myStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let photoViewController = myStoryboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
            
            photoViewController.image = imageView.image
            photoViewController.uid = self.user?.id
            photoViewController.myprofile = true
            if let photoImageView = imageView as? UserPhotoImageView {
                photoViewController.imagename = photoImageView.fileName
            }
            self.present(photoViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: Delete Photo Listeners
    var selectedUserImageView:UserPhotoImageView?
    
    func createDeletePhotoListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(deletePhoto), name: NSNotification.Name.init("DeletePhoto"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(photoRemoved), name: NSNotification.Name.init("PhotoDeleted"), object: nil)
    }
    func removeDeletePhotoListener() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("DeletePhoto"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("PhotoDeleted"), object: nil)
        
    }
    func successfulDeletion() {
        selectedUserImageView?.image = UIImage(named: "noprofilepic")
        selectedUserImageView?.fileName = nil
        selectedUserImageView?.isUserInteractionEnabled = false
        /*if zoomingView != nil {
            customZoom?.handleZoomOutImageView(zoomOutImageView: zoomingView!)
        }*/
    }
    // MARK: Delete photo function
    @objc func deletePhoto() {
        let uid = Users.getCurrentUID()
        if selectedUserImageView != nil && selectedUserImageView?.fileName != nil {
            Users.findAndDeletePhotoWithFilename(filename: (selectedUserImageView?.fileName)!, userUID: uid)
        }
    }
    @objc func photoRemoved() {
        removeDeletePhotoListener()
        successfulDeletion()
        
        searchAndRemoveEmptyImageView()
    }
    // FIXME: Cycle through UIImageViews in ScrollView and Delete the imageview with photo "noprofilepic"
    func searchAndRemoveEmptyImageView() {
        for imageView in self.userScrollView.subviews {
            if let imageview = imageView as? UIImageView {
                if imageview.image == UIImage(named: "noprofilepic") {
                    if imageview == self.otherPhotoOneImageView || imageview == self.otherPhotoTwoImageView || imageview == self.otherPhotoThreeImageView {
                        
                    } else {
                        imageview.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    // MARK: TapGestureRecognizers
    func createTapGestureForProfilePic() -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openCamera))
        tapGesture.isEnabled = true
        return tapGesture
    }
    func createTapGestureForZoomIn() -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openPhotoView(taprecognizer:)))
        tapGesture.isEnabled = true
        return tapGesture
    }
    func createTapGestureForAddPhotos() -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addMorePhotos))
        tapGesture.isEnabled = true
        return tapGesture
    }
    @objc func addMorePhotos() {
        let camera:CameraPicker = CameraPicker(withVC: self)
        self.selectedTypeOfPhoto = .NewPhoto
        camera.presentPictureOptions()
    }
    @objc func moreOptions() {
        let options = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        options.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (action) in
            self.logOut()
        }))
        
        options.addAction(UIAlertAction(title: "Administrator Access", style: .default, handler: { (action) in
            self.checkAndOpenAdminControl()
        }))
        
        options.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(options, animated: true, completion: nil)
        
    }
    func checkAndOpenAdminControl() {
        if let userid = self.user?.id {
            if userid.compare("A0VWHJvaYRNBIiu7rldLDjoefX73") == ComparisonResult.orderedSame ||
                userid.compare("nWaCn7Zlu8S8UUbjyPhOfGV7kZo2") == ComparisonResult.orderedSame {
                self.openAdminControl()
            } else {
                let alert = UIAlertController(title: "Error", message: "You do not have administrator privileges", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func openAdminControl() {
        self.present(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdminViewController"), animated: true, completion: nil)
    }
    
    func createBarButtonItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(openCamera))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "...", style: .plain, target: self, action: #selector(moreOptions))

        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 18)], for: .normal)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        
    }
    @objc func logOut() {
        appDelegate.setOffline()
        
        let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            }
            catch let SignOutError {
                AlertController.showErrorOnVC(viewController: self, title: "Log out error", message: "Unable to log out: \n \(SignOutError)")
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.countries = Countries.getListOfCountries()
        
        loadingView = LoadingView(ViewController: self)
        self.user = EDUser()
        
        NavigationBar.setColourSchemeFor(navBar: (self.navigationController?.navigationBar)!)
        createBarButtonItems()
        
        self.textController.userUID = self.appDelegate.activeUser.uid
        checkSize()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if (loadingView != nil) {
            loadingView?.startLoading()
        }
        
    }
    
    
    func loadUserDetails() {
        if let profilePic = profilePicture {
            profilePicImageView.image = profilePic
            self.stopLoading()
        }
        let uid = Users.getCurrentUID()
        let database = Database.database().reference().child("users").child(uid)
        
        self.user?.id = uid
        
        database.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as?  NSDictionary {
            
            if let name = dictionary["name"] as? String {
                self.user?.name = name
                self.reloadTable()
            }
            
            if let country = dictionary["country"] as? String {
                self.user?.country = country
                self.reloadTable()
            }
            if let city = dictionary["city"] as? String {
                self.user?.city = city
                
                self.reloadTable()
            }

            if let about = dictionary["about"] as? String {
                self.user?.about = about
                self.reloadTable()
            }
            
            if let relationshipstatus = dictionary["relationship_status"] as? String {
                self.user?.relationship_status = relationshipstatus
            }
            if let lookingfor = dictionary["looking_for"] as? String {
                self.user?.looking_for = lookingfor
            }
            }
        })
        Users.getPhotosForUser(userUID: uid)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedOtherPhotos), name: NSNotification.Name.init("FoundOtherPhotos"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(foundNoPhotos), name: NSNotification.Name.init("NoPhotosFound"), object: nil)
        
        // Loaded user details.
        checkAndDisplayTutorial()
        checkForProfilePic()
    }
    
    @objc func foundNoPhotos() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("FoundOtherPhotos"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("NoPhotosFound"), object: nil)
    }
    
    var countOfExtraImageViews = 1
    @IBOutlet var userScrollView:UIScrollView!
    
    // Dynamically create ImageViews for Users photos
    func createImageView(xCoordinate: Int) -> UserPhotoImageView {
        let imageView = UserPhotoImageView(frame: CGRect.init(x: xCoordinate, y: 11, width: 80, height: 80))
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(createTapGestureForZoomIn())
        
        return imageView
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
                    // FIXME: Same code can be found in UserDetailVC. Find a way to refactor
                    let imageView = createImageView(xCoordinate: getXCoord())
                    self.userScrollView.addSubview(imageView)
                    imageView.loadImageUsingCacheWithUrlString(urlString: userImage.downloadUrl)
                    imageView.fileName = userImage.fileName
                    countOfExtraImageViews = countOfExtraImageViews + 1
                    
                    let newSize = CGSize(width: 400 + CGFloat(getExtraWidth()), height: 90)
                    self.userScrollView.contentSize = newSize
                    
                }
            }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("FoundOtherPhotos"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("NoPhotosFound"), object: nil)
    }
    
    
    func getXCoord() -> Int {
        return 279+getExtraWidth()
    }
    func getExtraWidth() -> Int {
        return 90*countOfExtraImageViews
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchForProfilePicture()
    }
    
    func searchForProfilePicture() {
        Users.downloadMyProfilePicture(self)
    }
    
    func fixOrientation(img:UIImage) -> UIImage {
        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    

    enum TypeOfPhoto {
        case ProfilePicture
        case NewPhoto
        case NoTypeSelected
    }
    var selectedTypeOfPhoto:TypeOfPhoto = .NoTypeSelected
    
    var newImage:UIImage?
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage:UIImage!
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        guard let imageData = UIImageJPEGRepresentation(selectedImage, 1.0) else {
            return
        }
        let photoIDString = NSUUID().uuidString
        if(picker.sourceType == UIImagePickerControllerSourceType.camera) {
            let image = self.fixOrientation(img: UIImage(data: imageData)!)
                setNewImage(image: image, photoFilename: photoIDString)
        } else {
            if let selectedImageD = UIImage(data: imageData) {
                setNewImage(image: selectedImage, photoFilename: photoIDString)
            }
        }
        
        defer {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let user = appDelegate.activeUser!
            
            picker.dismiss(animated: true) {
                self.createListener()
                self.uploadNewPhoto(user: user, imageData: imageData, photoFilename: photoIDString)
                DispatchQueue.main.async {
                    self.loadingView = LoadingView(ViewController: self)
                    self.loadingView?.startLoadingUpload()
                }
            }
        }
    }
    func uploadNewPhoto(user:User, imageData:Data, photoFilename:String) {
        if selectedTypeOfPhoto == .NewPhoto {
            Users.uploadMorePhotosForUser(userID: user.uid, photoData: imageData, photoIDString: photoFilename)
        } else if selectedTypeOfPhoto == .ProfilePicture {
            Users.uploadUserProfilePicToServer(user: user, profileImage: imageData)
        } else {
            print("ERROR: User did not select what type of photo to upload")
            print("See uploadNewPhoto in MyProfileVC")
        }
    }
    func createListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(uploadComplete), name: NSNotification.Name.init(rawValue: "UploadComplete"), object: nil)
    }
    
    func setNewImage(image: UIImage, photoFilename:String) {
        if selectedTypeOfPhoto == .NewPhoto {
            createThumbnailAndSetImage(image: image, photoFilename: photoFilename)
        } else if selectedTypeOfPhoto == .ProfilePicture {
            setNewProfileImage(image: image)
        } else {
            print("ERROR: User did not select what type of photo to upload")
            print("See setNewImage in MyProfileVC")
        }
    }
    @objc func uploadComplete() {
        if let loadingView = self.loadingView {
            loadingView.stopLoading()
            self.loadingView = nil
        }
        self.navigationItem.title = "Upload complete!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.resetTitle()
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(rawValue: "UploadComplete"), object: nil)
    }
    func resetTitle() {
        self.navigationItem.title = "My Profile"
    }
    
    func createThumbnailAndSetImage(image:UIImage, photoFilename:String) {
        var imageview:UserPhotoImageView
        
        if self.otherPhotoOneImageView.image == UIImage(named: "noprofilepic") {
            imageview = self.otherPhotoOneImageView
        } else if self.otherPhotoTwoImageView.image == UIImage(named: "noprofilepic") {
            imageview = self.otherPhotoTwoImageView
        } else if self.otherPhotoThreeImageView.image == UIImage(named: "noprofilepic") {
            imageview = self.otherPhotoThreeImageView
        } else {
            imageview = createImageView(xCoordinate: getXCoord())
            self.userScrollView.addSubview(imageview)
            
            countOfExtraImageViews = countOfExtraImageViews + 1
            let newSize = CGSize(width: 400 + CGFloat(getExtraWidth()), height: 90)
            self.userScrollView.contentSize = newSize
        }
        
        imageview.image = image
        imageview.fileName = photoFilename
    }
    
    func setNewProfileImage(image: UIImage) {
        self.profilePicture = image
        self.profilePicImageView.image = image
    }

    @objc func openCamera() {
        let camera:CameraPicker = CameraPicker(withVC: self)
        camera.presentFirstPictureOption()
    }

    func addProfilePicture() {
        let camera:CameraPicker = CameraPicker(withVC: self)
        self.selectedTypeOfPhoto = .ProfilePicture
        camera.presentPictureOptions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    var myProfileInfopicker:UIPickerView = {
        let newpicker = UIPickerView()
        newpicker.showsSelectionIndicator = true
        return newpicker
    }()
    
    func getPickerFor(pickerType:PickerSelectionType) -> UIPickerView {
        let myProfilePicker = UIPickerView()
        myProfilePicker.showsSelectionIndicator = true
        
        if pickerType == .RelationshipStatus {
            myProfilePicker.tag = 354
        } else {
            myProfilePicker.tag = 453
        }
        return myProfilePicker
    }
    enum PickerSelectionType {
        case RelationshipStatus
        case LookingFor
    }
    // FIXME: Fix this.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath) as! ProfileAboutTableViewCell
            cell.textView?.delegate = self.textController
            if let about = self.user?.about {
                if about == "" || about == " " {
                    cell.textView?.text = "Write something about yourself here..."
                } else {
                    cell.textView?.text = about
                }
            }
            return cell
        }
            
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! ProfileTableViewCell
            if let name = self.user?.name {
                cell.textField?.text = name
                cell.textField?.placeholder = "Name"
            } else {
                cell.textField?.text = "Name"
                cell.textField?.placeholder = "Name"
                //print("No name found.")
            }
            cell.textField?.delegate = self.textController
            cell.textField?.tag = 128
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! ProfileTableViewCell
            if let country = self.user?.country {
                if let city = self.user?.city {
                    cell.textField?.text = "\(city), \(country)"
                } else {
                    cell.textField?.text = "\(country)"
                }
            } else {
                cell.textField?.placeholder = "Location"
                //print("No location found.")
            }
            cell.textField?.delegate = self.textController
            cell.textField?.tag = 1
            cell.textField?.isUserInteractionEnabled = false
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! ProfileTableViewCell
            if let relationshipstatus = self.user?.relationship_status {
                cell.textField?.text = relationshipstatus
            }
            cell.textField?.placeholder = "Relationship status"
            cell.textField?.tag = 120
            cell.textField?.delegate = self.textController
            let profilePicker = self.getPickerFor(pickerType: PickerSelectionType.RelationshipStatus)
            profilePicker.delegate = self.textController
            profilePicker.dataSource = self.textController
            self.textController.relationshipStatusTextField = cell.textField
            cell.textField?.inputView = profilePicker
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! ProfileTableViewCell
            if let lookingfor = self.user?.looking_for {
                cell.textField?.text = lookingfor
            }
            cell.textField?.placeholder = "Looking for"
            cell.textField?.tag = 115
            cell.textField?.delegate = self.textController
            let profilePicker = self.getPickerFor(pickerType: PickerSelectionType.LookingFor)
            profilePicker.delegate = self.textController
            profilePicker.dataSource = self.textController
            self.textController.lookingForTextField = cell.textField
            cell.textField?.inputView = profilePicker
            return cell
        default:
            
            break
        }
        let cell:UITableViewCell = UITableViewCell.init()
        print("This message should not be displayed!! cellForRow in MyProfileVC")
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "About me:"
        } else {
            return "Bio:"
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0 && indexPath.section == 1) {
            return 250
        }
        else {
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            askToEditLocation()
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    var userUpdateLocation:UpdateUserLocation?
    
    func askToEditLocation() {
        let alertController = UIAlertController(title: "Change Location", message: "Tap 'Find My Location' to update your location\nOr enter your location manually", preferredStyle: .alert)
        
        let findMyLocationAction = UIAlertAction(title: "Find My Location", style: .default) { (action) in
            self.userUpdateLocation = UpdateUserLocation()
            
            self.userUpdateLocation?.delegate = self
            
        }
        let enterLocationManuallyAction = UIAlertAction(title: "Enter location manually", style: .default) { (action) in
            self.dismiss(animated: true, completion:nil)
            
            self.allowUserToEnterManualLocation()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        
        alertController.addAction(findMyLocationAction)
        alertController.addAction(enterLocationManuallyAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func returnUserLocation(location: CLLocation) {
        setLocationFromCLLocation(location: location)
    }
    
    var errorAlertController:UIAlertController?
    
    func allowUserToEnterManualLocation() {
        
         errorAlertController = UIAlertController(title: "Manual Location Entry", message: "Please enter your Location", preferredStyle: .alert)
        
        errorAlertController?.addTextField { (textField) in
            // Country
            textField.placeholder = "Country"
            textField.tag = 187
            textField.inputView = self.picker
            self.picker.delegate = self
            self.picker.dataSource = self
        }
        errorAlertController?.addTextField { (textField) in
            // City
            textField.placeholder = "City"
            textField.autocapitalizationType = .words
        }
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { (action) in
            var newCity:String?, newCountry:String?
            
            for textfield in (self.errorAlertController?.textFields)! {
                if textfield.text == "" {
                    return
                }
                if textfield.tag == 187 {
                    newCountry = textfield.text
                } else {
                    newCity = textfield.text
                }
            }
            self.updateNewUserLocation(country: newCountry!, city: newCity!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        errorAlertController?.addAction(doneAction)
        errorAlertController?.addAction(cancelAction)
        
        self.present(errorAlertController!, animated: true, completion:nil)
    }
    func returnErrorForLocation() {
         errorAlertController = UIAlertController(title: "Location Error", message: "Unable to find your location\nYou must enable Location Services to use this feature\nPlease enter your Location manually", preferredStyle: .alert)
        
        errorAlertController?.addTextField { (textField) in
            // Country
            textField.placeholder = "Country"
            textField.tag = 187
            textField.inputView = self.picker
            self.picker.delegate = self
            self.picker.dataSource = self
        }
        errorAlertController?.addTextField { (textField) in
            // City
            textField.placeholder = "City"
            textField.autocapitalizationType = .words
        }
        
        let doneAction = UIAlertAction(title: "Set", style: .default) { (action) in
            var newCity:String?, newCountry:String?
            
            for textfield in (self.errorAlertController?.textFields)! {
                if textfield.text == "" {
                    return
                }
                if textfield.tag == 187 {
                    newCountry = textfield.text
                } else {
                    newCity = textfield.text
                }
                
            }
            self.updateNewUserLocation(country: newCountry!, city: newCity!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        errorAlertController?.addAction(doneAction)
        errorAlertController?.addAction(cancelAction)
        
        self.present(errorAlertController!, animated: true, completion:nil)
    }
    
    func updateNewUserLocation(country:String, city:String) {
        Users.updateUserLocation(UID: self.appDelegate.activeUser.uid, Country: country, City: city)
        self.user?.country = country
        self.user?.city = city
        self.userUpdateLocation = nil
        (self.tableView?.cellForRow(at: IndexPath(row: 1, section: 0)) as! ProfileTableViewCell).textField?.text = "\(city), \(country)"
        self.tableView?.reloadData()
    }
    
    func setLocationFromCLLocation(location:CLLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarksArray, error) in
            if error != nil {
                //print("ERROR: ", error?.localizedDescription)
                self.returnErrorForLocation()
            } else {
                let placemark = placemarksArray?.first
                
                if let country = placemark?.country {
                    if let city = placemark?.locality {
                        // Update new location
                        self.updateNewUserLocation(country: country, city: city)
                    }
                } else {
                    print("error, no country.")
                    self.returnErrorForLocation()
                }
            }
        }
    }
    
    var picker:UIPickerView = {
        let newpicker = UIPickerView()
        newpicker.showsSelectionIndicator = true
        return newpicker
    }()
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return UIScreen.main.bounds.width
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.countries?[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries!.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //countryTextField.text = self.countries[row]
        for textfield in (errorAlertController?.textFields)! {
            if textfield.tag == 187 {
                textfield.text = self.countries?[row]
            }
        }
    }
}




