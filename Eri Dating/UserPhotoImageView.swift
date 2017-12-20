//
//  UserPhotoImageView.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 26/10/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit

class UserPhotoImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var fileName:String?
    
    func getFilename() -> String? {
        return fileName
    }

}
