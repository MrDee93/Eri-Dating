//
//  ThumbnailCreator.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 18/12/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import Foundation
import UIKit

class ThumbnailCreator {
    
    static func createThumbnail(withImage image:UIImage) -> UIImage {
        
        let imageData = UIImagePNGRepresentation(image)
        
        // 104 width, 87 height
        let size = CGSize.init(width: 104, height: 87)
        //let size = CGSize.init(width: 66, height: 66)
        
        let newImage = UIImage.init(data: imageData!)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        newImage?.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return thumbnail!
        
    }
    
    static func createThumbnail(withSize size:CGSize, image:UIImage) -> UIImage {
        let imageData = UIImagePNGRepresentation(image)
        
        // 104 width, 87 height
        
        let newImage = UIImage.init(data: imageData!)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        newImage?.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return thumbnail!
        
    }
}
/*
 NSData *imageData = UIImagePNGRepresentation(image);
 UIImage *newImage = [UIImage imageWithData:imageData];
 CGSize size = CGSizeMake(25, 25);
 
 UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
 [newImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
 UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 // return UIImagePNGRepresentation(thumbnail); - Returns NSData
 return thumbnail;
 */
