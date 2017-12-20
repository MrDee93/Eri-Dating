//
//  PhotoViewController.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 05/12/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet var photoImageView:UserPhotoImageView!
    @IBOutlet var toolbar:UIToolbar!
    
    var image:UIImage?
    var imagename:String?
    var uid:String?
    var myprofile:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupToolbar()
        
        // Do any additional setup after loading the view.
        setupView()
    }
    func setupToolbar() {
        var toolbarButton:UIBarButtonItem
        if myprofile != nil && myprofile == true {
            toolbarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteImage))
        } else {
            toolbarButton = UIBarButtonItem(title: "Report", style: .plain, target: self, action: #selector(reportImage))
            toolbarButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.red], for: .normal)
        }
        
        toolbar.items?.append(toolbarButton)
    }
    
    @objc func deleteImage() {
        NotificationCenter.default.post(name: NSNotification.Name.init("DeletePhoto"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView() {
        photoImageView.contentMode = .scaleAspectFit
        
        if let img = image {
            photoImageView.image = img
        }
    }

    @IBAction func cancelView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func reportImage() {
        self.present(ReportingFacility.reportPhoto(id: uid!, filename: imagename), animated: true, completion: {
            
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
