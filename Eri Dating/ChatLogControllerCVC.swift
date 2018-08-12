//
//  ChatLogControllerCVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 01/03/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox
import MobileCoreServices
import AVFoundation

private let reuseIdentifier = "cellId"

final class ChatLogControllerCVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ConnectedImageDelegate {
    
    var viewIsVisible:Bool?
    var messages = [Message]()
    
    var user:EDUser? {
        didSet {
            navigationItem.titleView = createTitleView(name: (user?.name)!)
            observeMessages()
        }
    }
    var loadedAllMessages:Bool = false
    var loadingMessages:Bool = false
    
    func createTitleView(name: String) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 15))
        
        onlineStatusImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        onlineStatusImageView.image = UIImage(named: "red")
        
        view.addSubview(onlineStatusImageView)
        let widthOfText = (FrameEstimator.estimateFrameForText(text: name)).width + 20
        
        let userLabel = UILabel(frame: CGRect(x: 10, y: 0, width: widthOfText, height: 15))
        userLabel.text = name
        userLabel.textAlignment = .center
        
        view.addSubview(userLabel)
        
        return view
    }
    var userConnectionStatus: UserConnectionStatus!
    
    var onlineStatusImageView: UIImageView! {
        didSet {
        onlineStatusImageView.layer.cornerRadius = 8
        onlineStatusImageView.layer.masksToBounds = true
        onlineStatusImageView.contentMode = .scaleAspectFill
        onlineStatusImageView.isUserInteractionEnabled = false
        }
    }
    func updateWithStatus(connectionStatus: ConnectionStatus) {
        setConnectionStatus(connectionStatus: connectionStatus)
    }
    func setConnectionStatus(connectionStatus:ConnectionStatus) {
        if connectionStatus == .Offline {
            onlineStatusImageView.image = UIImage(named: "red")
        } else if connectionStatus == .Online {
            onlineStatusImageView.image = UIImage(named: "green")
        }
    }
    private func scrollToBottom() {
        if (self.collectionView?.numberOfItems(inSection: 0))! <= 1 {
            return
        }
        let index = (self.collectionView?.numberOfItems(inSection: 0))!-1
        let indexPath = IndexPath(row: index, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
    }
    
    //FIXME: New addition, just remove it?? errors appear when signing out saying database listen failed permission_denied
    /*
    deinit {
        Database.database().reference().child("user-messages")
        print("Removed observers")
    }*/
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        
        self.userConnectionStatus = UserConnectionStatus(userUID: toId)
        self.userConnectionStatus.delegate = self
        
        loadingMessages = true
        
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            
            let messageRef = Database.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {
                    return
                }
                
                let message = Message(dictionary: dictionary)
                
                if message.chatPartnerId() == self.user?.id {
                    if(message.newmessage?.intValue == 1) && (message.toId == uid) {
                        message.newmessage = NSNumber(value: 0)
                        self.openedNewMessage(messageId: messageId)
                    }
                    
                    self.messages.append(message)
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                        self.scrollToBottom()
                    })
                    if(self.loadedAllMessages && (!self.loadingMessages))
                    {
                        if message.toId == uid {
                            self.vibrateForMessage()
                        }
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func openedNewMessage(messageId:String) {
        if (viewIsVisible!) {
            let userMessageReference = Database.database().reference().child("messages").child(messageId)
        userMessageReference.updateChildValues(["newmessage":0])
            scrollToBottom()
        }
    }
    
    func switchOffLoadingMsg() {
        loadingMessages = false
        loadedAllMessages = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        //self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0)
        
        self.collectionView!.register(ChatMessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.alwaysBounceVertical = true

        self.collectionView?.keyboardDismissMode = .interactive
        setupKeyboardObservers()
        
        createBackgroundTapRecognizer()
    }
    
    
    lazy var inputContainerView:ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        
        return chatInputContainerView
    }()
    
    @objc func handleUploadTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // Add videos
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeVideo as String, kUTTypeMovie as String]
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            handleVideoSelectedForUrl(videoUrl: videoUrl)
        } else {
            handleImageSelectedForInfo(info: info)
        }

        dismiss(animated: true, completion: nil)
    }
    private func handleVideoSelectedForUrl(videoUrl: URL) {
        let filename = NSUUID().uuidString + ".mov"
        
        let storageReference = Storage.storage().reference().child("message_videos").child(filename)
        let uploadTask = storageReference.putFile(from: videoUrl, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("Failed to upload video.", error!)
            }
            
            storageReference.downloadURL(completion: { (url, err) in
                if url != nil {
                    if let thumbnailImage = self.thumbnailImageForVideoUrl(videoUrl) {
                        // FIXME: EDIT SIZE OF VIDEO THUMBNAIL HERE.
                        let size = CGSize(width: 200, height: 200)
                        let newThumbnailImage = ThumbnailCreator.createThumbnail(withSize: size, image: thumbnailImage)
                        self.uploadToFirebaseStorageUsingImage(image: newThumbnailImage, completion: { (imageUrl) in
                            let properties:[String:Any] = ["imageUrl":imageUrl, "imageWidth": newThumbnailImage.size.width, "imageHeight": newThumbnailImage.size.height, "videoUrl":url]
                            
                            self.sendMessageWithProperties(properties: properties)
                        })
                        
                    }
                }
            })
            //if let storageUrl = metadata?.downloadURL()?.absoluteString {
                //print("Storage URL:", storageUrl)
                
            
            //}
            
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                print(completedUnitCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            print("Upload complete")
        }
    }
    
    private func thumbnailImageForVideoUrl(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            /*
            if thumbnailCGImage.width > 200 || thumbnailCGImage.height > 200 {
                return UIImage(cgImage: thumbnailCGImage, scale: 0.5, orientation: UIImageOrientation.right)
            }*/
            return UIImage(cgImage: thumbnailCGImage, scale: 1.0, orientation: UIImageOrientation.right)
        }
        catch let err {
            print(err)
        }
        
        
        return nil
    }
    
    private func handleImageSelectedForInfo(info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            // SET PHOTO
            uploadToFirebaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            })
        }
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.6) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed to upload image: ", error!)
                    return
                }
                ref.downloadURL(completion: { (url, err) in
                    if url != nil {
                        if let imageUrl = url?.absoluteString {
                        completion(imageUrl)
                        }
                    }
                })
                
            })
        }
    }
    
    
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        viewIsVisible = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        viewIsVisible = false
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.inputContainerView.inputTextField.becomeFirstResponder()
        scrollToBottom()
        switchOffLoadingMsg()
        checkIfIAmBlocked()
    }
    func checkIfIAmBlocked() {
        if let userid = user?.id {
            UserBlocker.amIBlocked(targetUID: userid, chatLogVC: self)
        }
    }
    var blocked:Bool?
    
    func disableSendingMessages() {
        blocked = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        loadedAllMessages = false
        NotificationCenter.default.removeObserver(self)
    }
    func vibrateForMessage() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: Notification.Name.UIKeyboardDidShow, object: nil)
    }
    @objc func handleKeyboardDidShow() {
        scrollToBottom()
    }
    /*
    func handleKeyboardWillHide(notification: NSNotification) {
        containerViewBottomAnchor?.constant = 0
        
        
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
        
    }
    func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        // Move input area up.
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) { 
            self.view.layoutIfNeeded()
        }
        
    }*/
    @objc func resignTextField() {
        self.inputContainerView.inputTextField.resignFirstResponder()
    }
    func createBackgroundTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignTextField))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.isEnabled = true
        self.collectionView?.addGestureRecognizer(tapRecognizer)
        //self.view.addGestureRecognizer(tapRecognizer)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    @objc func handleSend() {
        if self.inputContainerView.inputTextField.text == "" {
            return
        }
        if blocked != nil && blocked == true {
            self.inputContainerView.inputTextField.text = ""
            return
        }
        let properties:[String:Any] = ["text":self.inputContainerView.inputTextField.text!]
        sendMessageWithProperties(properties: properties)
        self.inputContainerView.inputTextField.text = nil
    }
    
    
    private func sendMessageWithImageUrl(imageUrl:String, image:UIImage) {
        let properties:[String:Any] = ["imageUrl":imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height ]
       sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String : Any]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        var values = ["toId":toId, "fromId":fromId, "timestamp":timestamp, "newmessage":1] as [String : Any]
        
        // append properties dict onto values
        properties.forEach({ values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1]) // UNREAD
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessageRef.updateChildValues([messageId: 1])
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:IndexPath) -> CGSize {
        var height:CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            // h1 / w1 = h2 / w2
            // h1 = h2 / w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    func findSuitableImageSize(imageWidth:Float, imageHeight:Float) -> CGSize {
        
        return CGSize(width: CGFloat(imageWidth/5), height: CGFloat(imageHeight/5))
    }
    
    // FIXME: Created a new class, FrameEstimator. Use that instead.
    /*
    private func estimateFrameForText(text:String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }*/
    private func estimateFrameForText(text:String) -> CGRect {
        return FrameEstimator.estimateFrameForText(text:text)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatMessageCell
    
        cell.chatLogController = self
        cell.message = messages[indexPath.item]
        
        let message = cell.message!
        
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            // a text message
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            // set size for an image
            cell.textView.isHidden = true
            cell.bubbleWidthAnchor?.constant = 200
            cell.messageImageView.contentMode = .scaleAspectFit
        }

        // Hide if videoUrl is nil
        cell.playButton.isHidden = message.videoUrl == nil
        

        return cell
    }

    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let imageUrl = self.user?.profilePicUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            // outgoing blue
            //cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.bubbleView.backgroundColor = UIColor.getGreen()
            
            cell.textView.textColor = UIColor.white
            
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            // incoming grey
            //cell.bubbleView.backgroundColor = ChatMessageCell.grayColor
            cell.bubbleView.backgroundColor = UIColor.getRed()
            
            cell.textView.textColor = UIColor.white
            //cell.textView.textColor = UIColor.black
            
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // Custom zooming logic
    var startingFrame: CGRect?
    var blackBackgroundView:UIView?
    var startingImageView:UIImageView?
    
    
    // FIXME: Create a performZoomIn function here that instead uses CustomImageZoom class. and remember to resignTextField before calling the class
    /*
    func newperformZoomInForStartingImageView(startingImageView: UIImageView) {
        resignTextField()
        
        CustomImageZoom.performZoomInForStartingImageView(startingImageView)
    }*/
    
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        resignTextField()
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        //zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.isUserInteractionEnabled = true
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(self.blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            
            //UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                //let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                
                
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
                zoomingImageView.center = keyWindow.center
                zoomingImageView.contentMode = .scaleAspectFit
                    
                    
                    
                }, completion:nil)
            
           
        }
    }
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            // need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                
            })
        }
    }
    
   
}





