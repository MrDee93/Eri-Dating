//
//  SignUpSecondPageVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 16/06/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class SignUpSecondPageVC: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet var continueButton:UIButton!
    @IBOutlet var countryTextField:UITextField!
    @IBOutlet var cityTextField:UITextField!
    
    var backgroundTapRecognizer:UITapGestureRecognizer!
    
    var countries:[String] = []
    
    // Data from first sign up view controller
    var userName:String?
    var userBirthDate:String?
    var userGender:Gender?
    
    
    
    var locationManager:CLLocationManager?
    var userLocation:CLLocation? {
        didSet {
            getLocationFromCLLocation(location: userLocation!)
            print("Getting user location....")
        }
    }
    var userCountry:String? {
        didSet {
            if let usercountry = userCountry {
                countryTextField.text = usercountry
            }
        }
    }
    var userCity:String? {
        didSet {
            if let usercity = userCity {
                cityTextField.text = usercity
                geoCoder?.cancelGeocode()
            }
        }
    }
    
    var geoCoder:CLGeocoder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.countries = Countries.getListOfCountries()
        countryTextField.delegate = self
        cityTextField.delegate = self
        cityTextField.inputAccessoryView = returnToolbar()
        self.backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        self.backgroundTapRecognizer.isEnabled = true
        self.view.addGestureRecognizer(self.backgroundTapRecognizer)
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Location"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getUserLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let countryText = countryTextField.text, let cityText = cityTextField.text {
            if countryText != "" && cityText != "" {
                if countryText.count > 2 && cityText.count > 2 {
                    enableContinueButton()
                }
            }
        }
    }
    func enableContinueButton() {
        continueButton.backgroundColor = UIColor.getRed()
        continueButton.isEnabled = true
    }
    func disableTextFieldsUserInteraction() {
        countryTextField.isUserInteractionEnabled = false
        cityTextField.isUserInteractionEnabled = false
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return UIScreen.main.bounds.width
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.countries[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTextField.text = self.countries[row]
    }
    
    @IBAction func countryEditingDidBegin(_ sender: UITextField) {
        let picker = UIPickerView()
        
        picker.dataSource = self
        picker.delegate = self
        sender.inputView = picker
        sender.inputAccessoryView = returnToolbar()
        picker.showsSelectionIndicator = true
    }
    
    
    
    func getUserLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestWhenInUseAuthorization()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        userLocation = locations.first
        //getLocationFromCLLocation(location: locations.last!)
        manager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AlertController.showErrorOnVC(viewController: self, title: "Location Error", message: "\(error.localizedDescription)\nPlease enter your country & city manually")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
    }
    func getLocationFromCLLocation(location:CLLocation) {
        geoCoder = CLGeocoder()
        
        geoCoder?.reverseGeocodeLocation(location) { (placemarksArray, error) in
            //if (placemarksArray?.count)! > 0 {
            //print("Count of locations:", placemarksArray?.count)
            if error != nil {
                print("ERROR: ", error?.localizedDescription as Any)
            } else {
                let placemark = placemarksArray?.first
                
                if let country = placemark?.country {
                    if let city = placemark?.locality {
                        print("City: \(city),  Country: \(country)")
                        self.userCity = city
                        self.userCountry = country
                        self.enableContinueButton()
                        self.disableTextFieldsUserInteraction()
                    }
                } else {
                    print("error, no country.")
                }
            }
        }
    }
    
    
    @IBAction func getLocation() {
        getUserLocation()
    }
    @objc func doneEditing() {
        self.view.endEditing(true)
    }

    func returnToolbar() -> UIToolbar {
        let screenWidth = UIScreen.main.bounds.size.width
        let height = 44
        
        let toolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: Int(screenWidth), height: height))
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneEditing))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        return toolbar
    }
    
    @objc func handleBackgroundTap() {
        self.view.endEditing(true)
    }
    func getCountry() -> String {
        return countryTextField.text!
    }
    func getCity() -> String {
        return cityTextField.text!
    }
    
    // MARK: - Navigation
    func dismissView() {
        self.dismiss(animated: true) {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.showMyProfileVC()
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "thirdPageVC" {
            if FBRegistration.checkFBData() == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    if let userEmail = FBRegistration.getFBEmail(), let uid = Auth.auth().currentUser?.uid, let username = self.userName, let dateofbirth = self.userBirthDate, let usergender = self.userGender {
                        Users.addUserToDB(email: userEmail, name: username, dateOfBirth: dateofbirth, country: self.getCountry(), city: self.getCity(), userUID: uid, gender: usergender)
                        FBRegistration.removeFBRegistration()
                        UserDefaults.standard.set(true, forKey: "ShowTutorial")
                        //UserDefaults.standard.synchronize()
                        self.dismissView()
                    }
                })
                
                return false
            }
        }
        return true
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "thirdPageVC" {
            let thirdPageVC = segue.destination as! SignUpThirdPageVC
            thirdPageVC.userName = self.userName
            thirdPageVC.userGender = self.userGender
            thirdPageVC.userBirthDate = self.userBirthDate
            
            thirdPageVC.userCountry = getCountry()
            thirdPageVC.userCity = getCity()
        }
        
    }
    

}
