//
//  UserPhoto.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 24/10/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit

final class UserPhoto {
    /* Class UserPhoto stores the image name with the download url so that an image can be found and deleted
     * if necessary
     */
    var fileName:String!
    var downloadUrl:String!
    var userImage:UIImage?
    
    init(image:UIImage, downloadurl:String, filename:String) {
        self.fileName = filename
        self.downloadUrl = downloadurl
        self.userImage = image
    }
    init(downloadurl:String, filename:String) {
        self.fileName = filename
        self.downloadUrl = downloadurl
    }
    
    
    deinit {
        self.fileName = nil
        self.downloadUrl = nil
        self.userImage = nil
    }
}
