//
//  TermsOfUseVC.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 05/01/2018.
//  Copyright © 2018 Dayan Yonnatan. All rights reserved.
//

import UIKit

class TermsOfUseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .done, target: self, action: #selector(showOptions))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(showOptions))
    }
    @objc func showOptions() {
        let alert = UIAlertController(title: "Terms of Use", message: "You must read & Agree to Eri Dating Terms of Use before using this app.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "I agree", style: .default, handler: { (action) in
            UserDefaults.standard.set(true, forKey: "TermsOfUseAgreed")
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "I disagree (This app will close)", style: .destructive, handler: { (action) in
            UserDefaults.standard.set(false, forKey: "TermsOfUseAgreed")
            exit(0)
        }))
        self.present(alert, animated: true, completion: nil)
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
