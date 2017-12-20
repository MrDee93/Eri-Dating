//
//  Countries.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 16/06/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import Foundation

class Countries {
    static func getListOfCountries() -> [String] {
        var countries: [String] = []
    
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }
        return countries
    }
    
    static func getCountOfCountries() -> Int {
        return self.getListOfCountries().count
    }
}
