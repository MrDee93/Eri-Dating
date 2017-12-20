//
//  NavigationBar.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 18/05/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit

class NavigationBar {
    var navigationBar:UINavigationBar?
    
    // The colour scheme of the App.
    static func setColourSchemeFor(navBar:UINavigationBar) {
        navBar.barTintColor = UIColor.white
        navBar.tintColor = UIColor.red
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.getRed()]
    }
}
