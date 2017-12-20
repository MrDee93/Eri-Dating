//
//  SignUpFirstPageVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 15/06/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit

enum Gender {
    case Female
    case Male
}

class SignUpFirstPageVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var userNameTextField:UITextField!
    @IBOutlet var userBirthDateTextField:UITextField!
    @IBOutlet var genderSegmentControl:UISegmentedControl!
    
    @IBOutlet var continueButton:UIButton!
    
    var backgroundTapRecognizer:UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        self.backgroundTapRecognizer.isEnabled = true
        self.view.addGestureRecognizer(self.backgroundTapRecognizer)
        
        setupView()
        userNameTextField.delegate = self
        userBirthDateTextField.delegate = self
        genderSegmentControl.addTarget(self, action: #selector(genderSelected), for: .valueChanged)
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidLayoutSubviews() {
        checkFBData()
    }
    func checkFBData() {
        if FBRegistration.checkFBData() == true {
            
            if let name = FBRegistration.getFBName() {
                userNameTextField.text = name
            }
            
            if let gender = FBRegistration.getFBGender() {
                if gender == "M" {
                    genderSegmentControl.selectedSegmentIndex = 0
                } else if gender == "F" {
                    genderSegmentControl.selectedSegmentIndex = 1
                }
            }
            
        }
    }
    
    func getBirthDate() -> String? {
        if let birthdate = userBirthDateTextField.text {
            return birthdate
        }
        return nil
    }
    func getName() -> String? {
        return userNameTextField.text
    }
    func getGender() -> Gender? {
        let gender = genderSegmentControl.selectedSegmentIndex
            
        if gender == 0 {
            return Gender.Male
        } else if gender == 1 {
            return Gender.Female
        } else {
            return nil
        }
    }
    @objc func genderSelected(_ sender:UISegmentedControl) {
        enableContinueIfAllFieldsAreComplete()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        enableContinueIfAllFieldsAreComplete()
    }
    func enableContinueIfAllFieldsAreComplete() {
        if(userNameFieldEmpty()) {
            return
        }
        if(genderFieldEmpty()) {
            return
        }
        if(birthDateFieldEmpty()) {
            return
            // HANDLE ERROR on all these if statements
        }
        print("All fields are complete!")
        continueButton.backgroundColor = UIColor.getRed()
        continueButton.isEnabled = true
    }
    
    func setupView() {
        NavigationBar.setColourSchemeFor(navBar: (self.navigationController?.navigationBar)!)
        
        self.navigationItem.title = "Sign up"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelRegistration))
    }
    
    
    @objc func cancelRegistration() {
        if FBRegistration.checkFBData() {
            let alertController = UIAlertController(title: "Error", message: "Unable to cancel Registration process.\nThis app requires a few details about yourself before you can begin using the app", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
     CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
     
     UIDatePicker *datePicker = [[UIDatePicker alloc] init];
     [datePicker setDatePickerMode:UIDatePickerModeDate];
     [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
     
     // Toolbar wasn't able to be created unless I specified a frame.
     UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
     
     UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
     UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditingDOB)];
     [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, doneButton, nil]];
     [toolbar setBarStyle:UIBarStyleBlack];
     
     // Putting the Date picker and toolbar in a UIView worked.
     UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, toolbar.frame.size.height+datePicker.frame.size.height)];
     [newView addSubview:datePicker];
     [newView addSubview:toolbar];
     
     newView.backgroundColor = [UIColor clearColor];
     self.dateOfBirthTextField.inputView = newView;

     */
    func returnToolbar() -> UIToolbar {
        let screenWidth = UIScreen.main.bounds.size.width
        let height = 44
        
        let toolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: Int(screenWidth), height: height))
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneEditingBirthDate))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        return toolbar
    }
    
    
    @objc func doneEditingBirthDate(_ sender:Any) {
        userBirthDateTextField.endEditing(true)
    }
    
    @IBAction func birthDateEditingDidBegin(_ sender: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.calendar = Calendar.current
        datePicker.maximumDate = Date.init(timeIntervalSinceNow: -504576000)

        sender.inputView = datePicker
        sender.inputAccessoryView = returnToolbar()
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        
    }
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        userBirthDateTextField.text = DateFormat.getStringFromDate(date: sender.date)
    }
    func birthDateFieldEmpty() -> Bool {
        if let fieldText = userBirthDateTextField.text {
            if fieldText.isEmpty || fieldText == "" || fieldText == " " {
                return true
            }
        } else {
            return true
        }
        
        return false
    }
    func userNameFieldEmpty() -> Bool {
        if let fieldText = userNameTextField.text {
            if fieldText.isEmpty || fieldText == "" || fieldText == " " {
                return true
            }
        } else {
            return true
        }
        
        return false
    }
    func genderFieldEmpty() -> Bool {
        let selectedSegmentIndex = genderSegmentControl.selectedSegmentIndex
        
        if selectedSegmentIndex == 0 || selectedSegmentIndex == 1 {
            return false
        }
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "secondPageVC" {
            let secondPageVC = segue.destination as! SignUpSecondPageVC
            secondPageVC.userName = getName()
            secondPageVC.userGender = getGender()
            secondPageVC.userBirthDate = getBirthDate()
        }
    }
    
    @objc func handleBackgroundTap() {
        self.view.endEditing(true)
    }

}
