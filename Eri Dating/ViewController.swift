//
//  ViewController.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 28/11/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var userLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("Showing main viewcontroller")
        getName()
        
    }
    
    @IBAction func openMyProfile(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let myProfileVC:MyProfileVC = storyboard.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        //self.navigationController?.pushViewController(myProfileVC, animated: true)
        self.present(myProfileVC, animated: true, completion: nil)
    }
    
    func getName() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let userEmail = appDelegate.FirebaseAuth.currentUser!.email
        
        userLabel.text = "User: \(userEmail!)"
    }

    @IBAction func signOut(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        /*
        if(!appDelegate.signOut()) {
            print("ERROR: FAILED TO SIGN IN")
        }*/
        appDelegate.signOut()
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

