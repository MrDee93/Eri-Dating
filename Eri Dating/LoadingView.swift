//
//  LoadingView.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 13/05/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit

class LoadingView:NSObject {
    var viewcontroller:UIViewController?
    var spinner:UIActivityIndicatorView?
    var alertController:UIAlertController?
    var runningStatus:Bool?
    
    
    init(ViewController viewc:UIViewController) {
        self.viewcontroller = viewc
        runningStatus = false
    }
    deinit {
        self.viewcontroller = nil
        self.spinner = nil
        self.alertController = nil
        
    }
    
    func startLoadingUpload() {
        if runningStatus != true {
        if let viewController = self.viewcontroller {
            alertController = UIAlertController.init(title: "Uploading image...", message: "\n\n", preferredStyle: .alert)
            spinner = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
            spinner?.center = CGPoint.init(x: 130.0, y: 65.5)
            spinner?.color = UIColor.black
            spinner?.startAnimating()
            alertController?.view.addSubview(spinner!)
            viewController.present(alertController!, animated: true)
            print("Showing Upload progress on View: %@", viewController)
            self.runningStatus = true
        } else {
            print("ERROR: No view to display loading view to.")
        }
        } else {
            print("Already displaying view.")
        }
    }
    func startLoading() {
        if runningStatus != true {
        if let viewController = self.viewcontroller {
            alertController = UIAlertController.init(title: "Loading...", message: "\n\n", preferredStyle: .alert)
            spinner = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
            spinner?.center = CGPoint.init(x: 130.0, y: 65.5)
            spinner?.color = UIColor.black
            spinner?.startAnimating()
            alertController?.view.addSubview(spinner!)
            viewController.present(alertController!, animated: true)
            self.runningStatus = true
        } else {
            print("ERROR: No view to display loading view to.")
        }
        } else {
            print("Already displaying view.")
        }
    }
    func stopLoading() {
        runningStatus = false
        spinner?.stopAnimating()
        spinner = nil
        
        // FIXME: Temporary change, test.
        // Instead of running dismiss on the viewcontroller, let's run it on the alertcontroller to ensure no other view is dismissed.
        //viewcontroller?.dismiss(animated: true, completion: nil)
        alertController?.dismiss(animated: true, completion: {
            self.alertController = nil
        })
    }
    
}
