//
//  UserListViewController.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 12/12/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class UserListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet var tableView:UITableView!
    
    var userList:[EDUser]? = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshList()
    }
    //var userList:[String] = ["Ben","Tom","Billy","Vienna"]
    //var userEmail:[String] = ["Ben@mail.com", "Tom@lol.com", "Billy@bob.com", "Vienna@mail.com"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userList != nil {
            return userList!.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userControlCell", for: indexPath)
        
        let selectedUser = userList![indexPath.row]
        
        cell.textLabel?.text = selectedUser.name
        cell.detailTextLabel?.text = selectedUser.id
        if let profileimageurl = selectedUser.profilePicUrl {
            cell.imageView?.loadImageUsingCacheWithUrlString(urlString: profileimageurl)
        } else {
            cell.imageView?.image = UIImage(named: "noprofilepic")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayOptions(user: userList![indexPath.row], indexPath:indexPath)
    }
    func showMorePhotos(user:EDUser) {
        let userphototvc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserPhotoListTableViewController") as! UserPhotoListTableViewController
        userphototvc.user = user
        
        self.present(userphototvc, animated: true, completion: nil)
    }
    func displayOptions(user:EDUser, indexPath:IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Check profile photo", style: .default, handler: { (action) in
            if let id = user.id {
                ProfilePhotoChecker.checkIfUserHasProfilePhoto(id)
            } else {
                print("No ID value")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Show Photos", style: .destructive, handler: { (action) in
            self.showMorePhotos(user: user)
            
        }))
        alert.addAction(UIAlertAction(title: "Erase User Data", style: .destructive, handler: { (action) in
            let confirmAlert = UIAlertController(title: "Deletion", message: "Are you sure you want to erase users data?\nAction cannot be reversed", preferredStyle: .alert)
            confirmAlert.addAction(UIAlertAction(title: "Confirm Delete", style: .destructive, handler: { (action) in
                if let uid = user.id {
                    self.eraseUserDBData(uid: uid)
                    self.userList?.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }))
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(confirmAlert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func eraseUserDBData(uid:String) {
        let ref = Database.database().reference().child("users").child(uid)
        
        ref.removeValue()
        
        eraseUserData(uid: uid)
    }
    func eraseUserData(uid:String) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://eri-dating.appspot.com")
        
        
        let imageRef = storageRef.child("user_other_photos/\(uid)/")
        
        imageRef.delete { (error) in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func refreshList() {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadUserList()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func downloadUserList() {
        let ref = Database.database().reference().child("users")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dataDictionary = snapshot.value as? NSDictionary {
                dataDictionary.enumerateKeysAndObjects({ (key, obj, stop) in
                    let objectKey = key as? String
                    let objectData = obj as? NSDictionary
                    
                    let user = EDUser(dictionary: objectData as! Dictionary)
                    self.userList?.append(user)
                    self.tableView.reloadData()
                })
                
                
                
                
            }
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
