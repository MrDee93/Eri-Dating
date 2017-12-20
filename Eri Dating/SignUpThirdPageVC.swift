//
//  SignUpThirdPageVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 15/06/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpThirdPageVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var userEmailTextField:UITextField!
    @IBOutlet var userPasswordTextField:UITextField!
    @IBOutlet var signUpButton:UIButton!
    
    // From first page
    var userName:String?
    var userBirthDate:String?
    var userGender:Gender?
    
    // From second page
    var userCountry:String?
    var userCity:String?
    
    var backgroundTapRecognizer:UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        checkFBData()
        self.backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneEditing))
        self.backgroundTapRecognizer.isEnabled = true
        self.view.addGestureRecognizer(self.backgroundTapRecognizer)
        
        userEmailTextField.delegate = self
        userPasswordTextField.delegate = self
        userEmailTextField.inputAccessoryView = returnToolbar()
        userPasswordTextField.inputAccessoryView = returnToolbar()
        
        userPasswordTextField.rightViewMode = .always
        userPasswordTextField.rightView = getRightButtonForPasswordField()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        checkFBData()
    }
    func checkFBData() {
        if FBRegistration.checkFBData() == true {
            
            if let email = FBRegistration.getFBEmail() {
                userEmailTextField.text = email
                userEmailTextField.isUserInteractionEnabled = false
            }
            
            
        }
    }
    
    func getRightButtonForPasswordField() -> UIView {
        let newView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 17))
        let frame = CGRect(x: 0, y: 0, width: 23, height: 17)
        let button = UIButton(frame: frame)
        button.setImage(UIImage(named: "eye-grey"), for: .normal)
        button.addTarget(self, action: #selector(togglePasswordField), for: .touchUpInside)
        
        newView.addSubview(button)
        return newView
        //return button
    }
    @objc func togglePasswordField(_ sender:Any) {
        let isuserPasswordTextFieldSecured = userPasswordTextField.isSecureTextEntry
        
        if(isuserPasswordTextFieldSecured) {
            
            let rightViewButton = userPasswordTextField.rightView?.subviews.last as! UIButton
            rightViewButton.setImage(UIImage(named: "eye"), for: .normal)
            
            userPasswordTextField.isSecureTextEntry = false
        } else {
            let rightViewButton = userPasswordTextField.rightView?.subviews.last as! UIButton
            rightViewButton.setImage(UIImage(named: "eye-grey"), for: .normal)
            
            userPasswordTextField.isSecureTextEntry = true
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        enableSignUpButtonIfFieldsAreComplete()
    }
    @IBAction func signUp() {
        self.createUserWith(email: userEmailTextField.text!, password: userPasswordTextField.text!)
    }
    func createUserWith(email:String, password:String) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                AlertController.showErrorOnVC(viewController: self, title: "Sign Up Error", message: error!.localizedDescription)
            } else {
                print("Successfully created user.")
                if let userUID = Auth.auth().currentUser?.uid {
                
                guard let username = self.userName, let userdateofbirth = self.userBirthDate, let usercountry = self.userCountry, let usercity = self.userCity, let usergender = self.userGender else {
                    return
                }

                    Users.addUserToDB(email: email, name: username, dateOfBirth: userdateofbirth, country: usercountry, city: usercity, userUID: userUID, gender:usergender)
                    UserDefaults.standard.setValue(1, forKey: "NewlyRegistered")
                    UserDefaults.standard.synchronize()
                } else {
                    print("NO USERUID")
                }
            }
        })
    }

    func enableSignUpButtonIfFieldsAreComplete() {
        if(isEmailFieldCorrect()) {
            if(isPasswordCorrect()) {
                signUpButton.isEnabled = true
                signUpButton.backgroundColor = UIColor.getRed()
            }
        }
    }
    func isEmailFieldCorrect() -> Bool {
        if let emailAddress = userEmailTextField.text {
            if emailAddress.contains("@") {
                return true
            }
        }
        
        return false
    }
    func isPasswordCorrect() -> Bool {
        if let password = userPasswordTextField.text {
            let countOfCharacters = password.count
            
            if(countOfCharacters > 5) {
                return true
            } else {
                print("ERROR: Choose a password longer than 5 characters")
            }
        }
        return false
    }
    
    func setupView() {
        self.navigationItem.title = "Login Details"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func returnToolbar() -> UIToolbar {
        let screenWidth = UIScreen.main.bounds.size.width
        let height = 44
        
        let toolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: Int(screenWidth), height: height))
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneEditing))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        //let newView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: toolbar.frame.size.height))
        //newView.addSubview(toolbar)
        
        return toolbar
    }

    @objc func doneEditing(_ sender:Any) {
        self.view.endEditing(true)
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
