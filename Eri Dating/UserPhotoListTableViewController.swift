//
//  UserPhotoListTableViewController.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 12/12/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserPhotoListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView:UITableView!
    
    var user:EDUser!
    
    var other_photos:[UserPhoto]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getOtherPhotos()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reloadTable() {
        self.reloadData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Table view data source

    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Profile Photo"
        } else {
            return "Other Photos"
        }
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if other_photos != nil {
            return (other_photos?.count)!
        } else {
            return 0
    }
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath)
        
        if indexPath.section == 1 {
            
        let row = indexPath.row
        // Configure the cell...
       
        if let downloadurl = other_photos?[row].downloadUrl {
            cell.imageView?.loadImageUsingCacheWithUrlString(urlString: downloadurl)
            if let filename = other_photos?[row].fileName {
                cell.textLabel?.text = filename
            }
        }

        } else {
            if let profilepicurl = user.profilePicUrl {
                cell.imageView?.loadImageUsingCacheWithUrlString(urlString: profilepicurl)
                cell.textLabel?.text = "Profile Photo"
            }
            
        }
        return cell
    }
    
    
     func reloadData() {
        self.tableView.reloadData()
    }
    
    func getOtherPhotos() {
        if user.id != nil {
            let ref = Database.database().reference().child("users").child(user.id!).child("other_photos")
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let snapshotResults = snapshot.value as? NSDictionary else {
                    print("snapshot result is nil")
                    return
                }
                
                for val in snapshotResults {
                    guard let dictionaryValue = val.value as? NSDictionary else {
                        print("Dictionary val is nil")
                        return
                    }
                    
                    if let imageUrl = dictionaryValue.value(forKey: "imageUrl") as? String {
                        guard let filename = dictionaryValue.value(forKey: "imageFilename") as? String else {
                            print("image filename is nil")
                            return
                        }
                        let userPhoto = UserPhoto(downloadurl: imageUrl, filename: filename)
                        
                        self.other_photos?.append(userPhoto)
                        self.reloadData()
                    }
                }
            })
            
        }
    }
    func deletePhoto(uid:String?, filename:String?) {
        guard let id = uid, let fname = filename else {
            return
        }
        
        Users.findAndDeletePhotoWithFilename(filename: fname, userUID: id)
        self.reloadData()
    }
    func deleteProfilePhoto(uid:String?) {
        // delete profileimageurl entry in users
        // delete file from storage/user_profile_pics/UID.jpg
        
        if let id = uid {
            Users.removeUserProfilePic(uid: id)
            self.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        if indexPath.section == 1 {
            guard let userSelectedPhoto = other_photos?[row] else {
                return
            }
            let alert = UIAlertController(title: "Photo Options", message: userSelectedPhoto.fileName, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    self.deletePhoto(uid: self.user.id, filename: userSelectedPhoto.fileName)
                    self.other_photos?.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Photo Options", message: "Profile Photo", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    self.deleteProfilePhoto(uid: self.user.id)
                    self.user.profilePicUrl = nil
                    self.tableView.cellForRow(at: indexPath)?.imageView?.image = nil
                
                }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    /*
     let ref = Database.database().reference().child("users").child(userUID).child("other_photos")
     
     ref.observeSingleEvent(of: .value) { (snapshot) in
     
     guard let snapshotResults = snapshot.value as? NSDictionary else {
     NotificationCenter.default.post(name: NSNotification.Name.init("NoPhotosFound"), object: nil)
     return
     }
     
     for val in snapshotResults {
     guard let dictValue = val.value as? NSDictionary else {
     NotificationCenter.default.post(name: NSNotification.Name.init("NoPhotosFound"), object: nil)
     return
     }
     
     let imageUrl = dictValue.value(forKey: "imageUrl") as! String
     
     if let imageFilename = dictValue.value(forKey: "imageFilename") as? String {
     let userImage = UserPhoto(downloadurl: imageUrl, filename: imageFilename)
     arrayOfUserImages.append(userImage)
     }
     }
     
     if arrayOfUserImages.count >= 1 {
     NotificationCenter.default.post(name: NSNotification.Name.init("FoundOtherPhotos"), object: nil)
     } else {
     NotificationCenter.default.post(name: NSNotification.Name.init("NoPhotosFound"), object: nil)
     }
     
     }
 */
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
