//
//  AlertController.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 14/12/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import Foundation
import UIKit

class AlertController {

    static func showErrorOnVC(viewController:UIViewController, title:String, message:String) {
        let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissButton:UIAlertAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        alert.addAction(dismissButton)
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
