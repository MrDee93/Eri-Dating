//
//  BrowseCVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 28/11/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase
import FirebaseDatabase


private let reuseIdentifier = "Cell"
var arrayOfUsers = [EDUser]()



class BrowseCVC: UICollectionViewController {
    
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    var loadingView:LoadingView? {
        didSet {
            self.loadingView?.startLoading()
        }
    }
    var timer:Timer?
    var countOfLoadedProfiles = 0 {
        didSet {
            if let countOfUsers = self.fetchedResultsController?.fetchedObjects?.count {
                if countOfLoadedProfiles == countOfUsers {
                    self.deinitialiseLoadingView()
                }
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView?.reloadData()


    }
    @objc func loadBrowseView() {
        self.tabBarController?.selectedIndex = 0
        self.collectionView?.reloadData()
    }
    func setupLoadingView() {
        loadingView = LoadingView(ViewController: self)
    }
    
    func deinitialiseLoadingView() {
        if loadingView != nil {
        loadingView?.stopLoading()
        loadingView = nil
        }
    }
    
    
    /*
     You can't assume viewDidLoad will be called only once. If you are initializing objects and want a guarantee do the initialization either in the init method or if you are loading from a nib file from the awakeFromNib method.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        // FIXME: Setting tab bar controller index to 1 causes Chat window to open as it should, however the BrowseCVC page becomes buggy with same photo in multiple views.
        //self.tabBarController?.selectedIndex = 1
        //setupLoadingView()
        loadChatView()
        self.countOfLoadedProfiles = 0
        
        self.collectionView?.alwaysBounceVertical = true
        setupNotifications()
        setupFetch()

        self.navigationItem.title = "Explore"
        setNavigationColor()
    }
    func loadChatView() {
        if let navigationController = self.tabBarController?.viewControllers![1] as? UINavigationController {
            if let chatViewController = navigationController.viewControllers[0] as? MessagesTVC {
                if chatViewController.view == nil {
                    // Do nothing. this should load the view
                }
            }
            
        }
    }

    
    func setNavigationColor() {
        // Set top navigation bar colors
        NavigationBar.setColourSchemeFor(navBar: (self.navigationController?.navigationBar)!)

        self.navigationController?.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.tabBarController?.tabBar.tintColor = UIColor.getRed()
        
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(performFetch), name: NSNotification.Name.init("FetchData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: NSNotification.Name.init("DataChanged"), object: nil)
    }
    
    @objc func dataChanged() {
        self.collectionView?.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("FetchData"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("DataChanged"), object: nil)
    }
    
    func setupFetch() {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UsersDB")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "UsersInDB")

        prepareDB()
    }
    
    func prepareDB() {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.persistentContainer.viewContext.performAndWait {
            Users.clearUsersFromDB(appDelegate: appDelegate)
        }
        
        appDelegate.persistentContainer.viewContext.performAndWait {
            Users.getUsersFromDB(appDelegate: appDelegate)
        }
        
        //deinitialiseLoadingView()
    }

    @objc func performFetch() {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            do {
                try self.fetchedResultsController?.performFetch()
            }
            catch {
                print("Failed to fetch: \(error)")
            }
        defer {
            self.collectionView?.reloadData()
        }
    }
    
    
    @IBAction func refreshData(_ sender: Any) {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.persistentContainer.viewContext.performAndWait {
            self.prepareDB()
        }
        self.collectionView?.reloadData()
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "showUserDetail" {
            let sourceCVC = sender as! UserCollectionViewCell
            var selectedUser:EDUser = EDUser()
            selectedUser = sourceCVC.user
            
            let userDetailVC = segue.destination as! UserDetailVC

            userDetailVC.setUser(user: selectedUser)
        }
    }
 

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(fetchedResultsController?.fetchedObjects != nil) {
            return fetchedResultsController!.fetchedObjects!.count
        } else {
            return 0
        }
    }
    var usersConnectionStatus:[EDUser:ConnectedImage]?
    
    // FIXME: See if this is used, if not refactor out!
    /*func userStatusExists(uid:String) -> Bool {
        if usersConnectionStatus != nil {
        for userconnectionstatus in usersConnectionStatus! as [EDUser:ConnectedImage] {
            let user = userconnectionstatus.key
            let caughtID = user.id
            if(caughtID == uid) {
                return true
            }
        }
        }
        return false
    }*/
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:UserCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserCollectionViewCell
        
        let index:Int = indexPath.row
        let userDB:UsersDB = fetchedResultsController!.fetchedObjects![index] as! UsersDB

        let user:EDUser = Users.createUserFromCoreDataDB(userDB: userDB)
        
        
        if let usersName = userDB.name {
            cell.userLabel.text = usersName
        }
        
        cell.user = user
        
        
        if user.id != nil {
            cell.userConnectionImage?.delegate = cell
        }
        
        
        if let profileImageUrl = userDB.profilePicUrl {
            cell.user.profilePicUrl = profileImageUrl
            
            DispatchQueue.main.async {
                cell.userImage.layer.cornerRadius = 16
                cell.userImage.layer.masksToBounds = true
                cell.userImage.contentMode = .scaleAspectFill
                cell.userImage.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                
                self.countOfLoadedProfiles += 1
            }
        } else {
             cell.userImage.image = UIImage(named: "noprofilepic")
             cell.userImage.layer.cornerRadius = 16
             cell.userImage.layer.masksToBounds = true
             cell.userImage.contentMode = .scaleAspectFill
            
        }
        
        return cell
    }
    
    
    // ConnectedImage Delegate
    /*
    func updateTableWith(indexpath:IndexPath, image:UIImage) {
        //self.collectionView?.reloadData()
        
        //self.collectionView?.reloadItems(at: [indexpath])
        //let cell = self.collectionView(self.collectionView!, cellForItemAt: indexpath) as! UserCollectionViewCell
        
        //cell.onlineStatusImageView.image = image
        print("Update \(indexpath) with new image")
    }*/
    
    
    
    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }


}
