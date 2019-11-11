//
//  LocationManager.swift
//  ProManager
//
//  Created by Jatin Kathrotiya on 06/09/17.
//  Copyright © 2017 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationUpdateProtocol: class {
    func locationDidUpdateToLocation(location : CLLocation)
}

class LocationManager : NSObject, CLLocationManagerDelegate {
    static let sharedInstance : LocationManager = {
        let instance = LocationManager()
        return instance
    }()
    
    private var locationManager = CLLocationManager()
    var currentLocation : CLLocation?
    weak var delegate : LocationUpdateProtocol?
    
    private override init () {
        super.init()
        
        locationManager.requestWhenInUseAuthorization()
       
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        }
        
        if let location = Defaults.shared.currentLocation {
            currentLocation = location
        }
    }
    
    func refreshLocation() {
       if CLLocationManager.locationServicesEnabled() {
           locationManager.delegate = self
           locationManager.startUpdatingLocation()
       }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            manager.stopUpdatingLocation()
            Defaults.shared.currentLocation = self.currentLocation
            DispatchQueue.main.async {
                self.delegate?.locationDidUpdateToLocation(location: self.currentLocation!)
            }
            self.locationManager.delegate = nil
            self.locationManager.stopUpdatingLocation()
        }
    }
}
