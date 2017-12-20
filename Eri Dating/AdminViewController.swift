//
//  AdminViewController.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 12/12/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import FirebaseDatabase
/*
 let values = ["comment":"A comment",
 "timestamp":dateFormat.string(from: timestamp),
 "photofilename":"photo Name",
 "uid":"owner of photo uid"
 ]
 */


class AdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var refreshControl:UIRefreshControl!
    
    var reports:[Report]! = []
    
    
    @IBOutlet var tableView:UITableView!
    
    struct Report {
        var folderName:String
        var reportType:String
        var comment:String?
        var timestamp:String
        var filename:String?
        var uid:String?
    }
    
    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
        self.fetchReports()
    }
    @objc func refreshTable() {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func fetchReports() {
        let reportRef = Database.database().reference().child("Reports")
        
        reportRef.observeSingleEvent(of: .value) { (snapshot) in
            if let firstDictionaryDirectory = snapshot.value as? NSDictionary {
                
                
                firstDictionaryDirectory.enumerateKeysAndObjects({ (key, object, stop) in
                    //print("Object: ", object)
                    if let objectData = object as? NSDictionary {
                    
                        let report = Report(folderName: key as! String, reportType: objectData.value(forKey: "reportType") as! String, comment: objectData.value(forKey: "comments") as? String, timestamp: objectData.value(forKey: "timestamp") as! String, filename: objectData.value(forKey: "photoFilename") as? String, uid: objectData.value(forKey: "uid") as? String)
                        self.reports.append(report)
                        self.tableView.reloadData()
                    
                    }
                })
            }
        }
        
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func removeReport(report:Report) {
        let databaseReference = Database.database().reference().child("Reports").child(report.folderName)
        
        databaseReference.removeValue()

    }
    // MARK: Table View methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        let alert = UIAlertController(title: "Options", message: "If this Report has been solved, please remove it from the list.", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete this Report", style: .destructive, handler: { (action) in
            self.removeReport(report: self.reports[row])
            
            self.reports.remove(at: row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminAccessCell", for: indexPath)
        
        let row = indexPath.row
        
        let report = self.reports[row]
        
        if report.comment != nil {
            cell.textLabel?.text = "\(report.reportType): \(report.comment!)"
            cell.detailTextLabel?.text = report.timestamp
        } else {
            cell.textLabel?.text = "\(report.reportType): \(report.timestamp)"
        }
        
        if report.reportType == "User" {
            let ref = Database.database().reference().child("users").child(report.uid!).child("profileimageurl")
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let urlString = snapshot.value as? String {
                    cell.imageView?.loadImageUsingCacheWithUrlString(urlString: urlString)
                }
            }
            
        } else {
        if(report.filename == nil) || (report.filename == "Profile") {
            let ref = Database.database().reference().child("users").child(report.uid!).child("profileimageurl")
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let urlString = snapshot.value as? String {
                    cell.imageView?.loadImageUsingCacheWithUrlString(urlString: urlString)
                }
            }
        } else if (report.filename != nil) && (report.uid != nil) {
            let ref = Database.database().reference().child("users").child(report.uid!)
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                guard let snapshotResults = snapshot.value as? NSDictionary else {
                    print("Guard statement exit")
                    return
                }
                
                for imageFolder in snapshotResults {
                    let keyName = imageFolder.key as! String
                    if keyName == "other_photos" {
                        for imageData in imageFolder.value as! NSDictionary {

                            let imageDataDictionary = imageData.value as! NSDictionary // Get the imageFilename & imageUrl dictionary datas
                            
                            if let foundFilename = imageDataDictionary.value(forKey: "imageFilename") as? String {
                                if report.filename?.compare(foundFilename) == ComparisonResult.orderedSame {
                                    
                                if let urlString = imageDataDictionary.value(forKey: "imageUrl") as? String {
                                    cell.imageView?.loadImageUsingCacheWithUrlString(urlString: urlString)
                                }
                                }    }    } }     } } }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return list of items
        if reports != nil && reports.count >= 1 {
            return reports.count
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
