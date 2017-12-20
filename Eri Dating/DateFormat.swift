//
//  DateFormat.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 14/12/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import Foundation

class DateFormat {
    
    static func getDateFromString(string:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let date:Date = dateFormatter.date(from: string)!
        return date
    }
    static func getStringFromDate(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let string:String = dateFormatter.string(from: date)
        return string
    }
    
}
