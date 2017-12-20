//
//  ResetPasswordVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 17/06/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordVC: UIViewController {

    @IBOutlet var emailTextField:UITextField!
    
    var backgroundTapRecognizer:UITapGestureRecognizer!
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneEditing))
        self.backgroundTapRecognizer.isEnabled = true
        self.view.addGestureRecognizer(self.backgroundTapRecognizer)
        
        
        self.navigationItem.title = "Password Reset"
        NavigationBar.setColourSchemeFor(navBar: (self.navigationController?.navigationBar)!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func doneEditing() {
        self.view.endEditing(true)
    }
    
    @IBAction func submitReset() {
        if let email = emailTextField.text {
            sendResetLinkFor(email: email)
        }
    }
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    func sendResetLinkFor(email:String) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            if error != nil {
                AlertController.showErrorOnVC(viewController: self, title: "Reset Password Error", message: "Unable to find a match for the email address\nPlease make sure the email address is typed correctly.")
            } else {
                print("Sent password reset email!")
                let alertcontroller = UIAlertController(title: "Success!", message: "The link to reset your password has been sent to the email\n\nFollow the steps in the email to complete the password reset", preferredStyle: .alert)
                alertcontroller.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: { (action) in
                    self.dismiss(animated: true, completion:nil)
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.goBack), userInfo: nil, repeats: false)
                    self.timer?.fire()
                }))
                
                self.present(alertcontroller, animated: true, completion: nil)
            }
        })
        
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
