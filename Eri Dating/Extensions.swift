//
//  Extensions.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 01/03/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
   
    func loadImageUsingCacheWithUrlString(urlString: String) {
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            //print("Found cached image")
            return
        }
        
        //otherwise fire off a new download
        let url = NSURL(string: urlString)
        
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                    
                }
            })
            
        }).resume()
    }
    
    func loadImageWithUrlStringAndCustomSize(urlString: String, size:CGSize) {
        
        self.image = nil
        
        //otherwise fire off a new download
        let url = NSURL(string: urlString)
        
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    /* Image would not be sized to fit the ProfileImageView so we obtain a smaller version of the image for faster loading purposes as well as being able to fit even if a bug made the image too large.
                     One issue with using this is that the image will be lower resolution and if you attempt to enlarge the image, it would be much smaller so refrain from using it on images which can be enlarged.
                     */
                    let newImageThumbnail = ThumbnailCreator.createThumbnail(withSize: size, image: downloadedImage)
                    
                    self.image = newImageThumbnail
                    
                    
                }
            })
            
        }).resume()
    }
    
    func loadImageUsingCacheWithUrlString(urlString: String, size:CGSize) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = NSURL(string: urlString)
        
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    /* Image would not be sized to fit the ProfileImageView so we obtain a smaller version of the image for faster loading purposes as well as being able to fit even if a bug made the image too large.
                     One issue with using this is that the image will be lower resolution and if you attempt to enlarge the image, it would be much smaller so refrain from using it on images which can be enlarged.
                     */
                    let newImageThumbnail = ThumbnailCreator.createThumbnail(withSize: size, image: downloadedImage)
                    
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = newImageThumbnail
                    
                    
                }
            })
            
        }).resume()
    }
    
}
