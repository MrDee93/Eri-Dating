//
//  LoginVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 28/11/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import UIKit
import FacebookCore
import FBSDKLoginKit
import FirebaseAuth

class LoginVC: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var termsOfUseSwitch:UISwitch!
    @IBOutlet var termsOfUseLabel:UILabel!
    @IBOutlet var signInStackView:UIStackView!

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    @IBOutlet var signInButton:UIButton!
    {
        didSet {
            signInButton.layer.cornerRadius = 10
        }
    }
    
    
    var fbSetup:Bool = false
    var facebookLoginButton:FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("View did load loginvc")
        facebookLoginButton = FBSDKLoginButton()
        
        setupLoginManager()
        
        // Do any additional setup after loading the view.
        
        createGestureRecognizers()
    }
    @objc func openTermsOfUse() {
        print("Open terms of use!")
    }
    func createGestureRecognizers() {
        termsOfUseLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTermsOfUse)))
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func setupLoginManager() {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.loginManager = FBSDKLoginManager()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!fbSetup) {
            print("SETTING UP FACEBOOK LOGIN@@@@@@@@")
            fbSetup = true
            setupFacebookLogin()
        }
    }
   
    func setupFacebookLogin() {
        
        facebookLoginButton.delegate = self
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let arrayOfPermissionsRequired = Array(["public_profile", "email"])
        
        facebookLoginButton.readPermissions = arrayOfPermissionsRequired
        

        self.signInStackView.insertArrangedSubview(facebookLoginButton, at: 1)
        
        //facebookLoginButton.frame = getFacebookFrame()
        findAndRemoveFBHeightConstraint()
        adjustHeight()
    }
    func findAndRemoveFBHeightConstraint() {
        for constraint in facebookLoginButton.constraints {
            if constraint.constant == 28 {
                constraint.isActive = false
            }
        }
    }
    
    func adjustHeight() {
        print("Adjusting height")
        //let height = facebookLoginButton.frame.height
        let width = facebookLoginButton.frame.width
        let x = facebookLoginButton.frame.origin.x
        let y = facebookLoginButton.frame.origin.y
        
        let newHeight = CGFloat(48) //height + CGFloat(20)
        let newWidth = CGFloat(200)
        
        facebookLoginButton.frame = CGRect(x: x, y: y, width: newWidth, height: newHeight)
        
        let facebookHeightAnchor = facebookLoginButton.heightAnchor.constraint(equalToConstant: newHeight)
        facebookHeightAnchor.isActive = true
        facebookHeightAnchor.priority = UILayoutPriority(1000)
        let facebookWidthAnchor = facebookLoginButton.widthAnchor.constraint(equalToConstant: newWidth)
        facebookHeightAnchor.isActive = true
        facebookHeightAnchor.priority = UILayoutPriority(1000)
    }
    
    
    func getFacebookFrame() -> CGRect {
        let x = self.signInButton.frame.origin.x - 40
        let y = self.signInButton.frame.origin.y + 60
        
        let width = self.signInButton.frame.width //+ 80
        let height = self.signInButton.frame.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    var loadingView:LoadingView?
    var FBCredentials:AuthCredential?
    
    // MARK: FacebookLoginButton delegate method
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if result.token != nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            FBCredentials = credential

            FBRegistration.setFBRegistrationTrue()
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else if user != nil {
                    self.loginResult = result
                    if let uid = user?.uid {
                        self.checkUIDInDB(uid)
                    }
                }
            })
        }
    }
    
    var loginResult:FBSDKLoginManagerLoginResult?
    @objc func userNotFound() {
        removeDBListeners()
        if let result = loginResult {
            self.getUserDataFromFacebook(result)
        }
    }
    @objc func userDetailsFound() {
        FBRegistration.setFBRegistrationFalse()
        removeDBListeners()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        appdelegate.showMain()
    }
    func setupDBListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(userNotFound), name: NSNotification.Name.init(rawValue: "UserDetailsNotFound"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDetailsFound), name: NSNotification.Name.init(rawValue: "UserDetailsFound"), object: nil)
    }
    func removeDBListeners() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(rawValue: "UserDetailsNotFound"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(rawValue: "UserDetailsFound"), object: nil)
    }
    
    func checkUIDInDB(_ uid:String) {
        setupDBListeners()
        Users.findUserDetails(uid)
    }
    func pushRegistrationViewForFB() {
        let myStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let signUpNavigationController = myStoryboard.instantiateViewController(withIdentifier: "SignUpNavigationController") as? UINavigationController else {
            return
        }
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.presentCustom(viewController: signUpNavigationController)
        //self.present(signUpNavigationController, animated: true, completion: nil)
    }
    
    func getUserDataFromFacebook(_ result: FBSDKLoginManagerLoginResult!) {
        var public_profile:Bool = false
        
        if let grantedPermissions = result.grantedPermissions as? Set<String> {
            print(grantedPermissions)
            for grantedP in grantedPermissions {
                if grantedP == "public_profile" {
                    public_profile = true
                }
            }
        }
        
        if public_profile == true {
            print("Received public profile.")
            fetchData()
        }
    }
    
 
    func cleanString(_ string:String) -> String {
        return string.replacingOccurrences(of: " , ", with: "").replacingOccurrences(of: ", ", with: "")
    }
    func fetchData() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, name, gender"]).start(completionHandler: { (requestconn, result, error) in
            let resultDictionary = result as! NSDictionary
            
            //var name:String?
           // var gender:String?
           // var email:String?

            if let name = resultDictionary.value(forKey: "name") as? String {
                //print("Name is: ", usersname)
                //name = usersname
                UserDefaults.standard.setValue(name, forKey: "FB-Name")
                UserDefaults.standard.synchronize()
            }
            if let gender = resultDictionary.value(forKey: "gender") as? String {
                //print("Users gender is: ", usergender)
                //gender = usergender
                UserDefaults.standard.setValue(gender, forKey: "FB-Gender")
                UserDefaults.standard.synchronize()
            }
            if let email = resultDictionary.value(forKey: "email") as? String {
                //print("Email is: ", usersemail)
                //email = usersemail
                
                UserDefaults.standard.setValue(email, forKey: "FB-Email")
                UserDefaults.standard.synchronize()
            }
            
            self.pushRegistrationViewForFB()
        })
    }

    func updateFirebaseDatabase(name:String?, gender:String?, email:String?) {
        let uid = Users.getCurrentUID()
        
        var dict = Dictionary() as [String:String]
        
        dict.updateValue(uid, forKey: "uid")
        if let username = name {
            dict.updateValue(username, forKey: "name")
        }
        if let useremail = email {
            dict.updateValue(useremail, forKey: "email")
        }
        
        Users.addUserToDB(userUID: uid, values: dict)
        
    }
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        //print("User logged out!")
    }
    
    @objc func handleBackgroundTap(_ sender:Any) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    @IBAction func debugModeTom(_ sender:Any) {
        emailTextField.text = "Tom@lol.com"
        passwordTextField.text = "tom123"
    }
    
    @IBAction func debugMode(_ sender: Any) {
        emailTextField.text = "Vienna@mail.com"
        passwordTextField.text = "nero123"
    }
    
    
    @IBAction func signIn(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            return
        }
        if (!termsOfUseSwitch.isOn) {
            print("Terms of use not accepted.")
            return
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.FirebaseAuth.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error != nil {
                    var errorString = error?.localizedDescription
                    if error?._code == 17009 {
                        errorString = "The password is invalid."
                    }
                    if error?._code == 17011 {
                        errorString = "Unable to find user with that email. \nPlease try again"
                    }
                    self.showError(title: "Failed to sign in", message: errorString!)
                } else {
                    print("Signed in as user: \(user!.email!)")
                    //appDelegate.showMain()
                    //self.navigationController?.dismiss(animated: false, completion: nil)
                }
            })
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showError(title:String, message:String) {
        let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissButton:UIAlertAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        alert.addAction(dismissButton)
        self.present(alert, animated: true, completion: nil)
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
