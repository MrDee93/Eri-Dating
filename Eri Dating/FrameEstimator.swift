//
//  FrameEstimator.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 24/10/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit


class FrameEstimator {
    
    static func estimateFrameForText(text:String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
}
