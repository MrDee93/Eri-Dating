//
//  UpdateUserLocation.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 17/06/2017.
//  Copyright © 2017 Dayan Yonnatan. All rights reserved.
//

import UIKit
import CoreLocation

protocol UpdateUserLocationDelegate:class {
    func returnUserLocation(location:CLLocation)
    func returnErrorForLocation()
}

class UpdateUserLocation:NSObject, CLLocationManagerDelegate {
    
    weak var delegate:UpdateUserLocationDelegate?
    
    var locationManager:CLLocationManager?
    var userLocation:CLLocation?
    {
        didSet {
            locationManager?.stopUpdatingLocation()
            delegate?.returnUserLocation(location: userLocation!)
        }
    }
    
    override init() {
        super.init()
        
        initialiseLocationManager()
    }
    
    func initialiseLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.notDetermined || status == CLAuthorizationStatus.restricted {
            // UNABLE TO GET LOCATION. USER MUST ENTER MANUALLY!
            delegate?.returnErrorForLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.returnErrorForLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
    }
    
}




