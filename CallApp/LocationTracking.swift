//
//  LocationTracking.swift
//
//
//  Created by Akash Singh Sisodia on 22/04/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//

import UIKit
import CoreLocation
public enum NSLocationFetchType {
    
    case continuous, orders
}
typealias LocationAuthCallback = (CLAuthorizationStatus)->Void

class LocationTracking: NSObject {
    
    var locationManager: CLLocationManager!
    var bestFitLocation: CLLocation =  CLLocation(latitude: 16.6953041, longitude: -71.5430)
    var previousFitLocationEta: CLLocation!
    var previousFitLocationMarker: CLLocation!
    var currentHeading = 0.0
    var updateMarker: Int = 0
    var updateLocationDistance: Int = 0
    var calculateEtaDistance: Int = Int()
    
    var callBackUpdateLocationMarker: (() -> Void)?
    var callBackUpdateLocationEta: (() -> Void)?
    var callBackAlwaysAuthorization:((Bool) -> (Void))?
    
    fileprivate var locationAuthHandler: LocationAuthCallback!
    var fetchType: NSLocationFetchType = .orders
    static var shared: LocationTracking = {
        let locationTracking = LocationTracking()
        locationTracking.configure()
        return locationTracking
    }()
    
    private func configure() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        requestAuthorization { (permission) in
            guard self.isValidStatus(permission) else {
                return
            }
            self.startManager(type: .orders)
        }
    }
    
    private func requestAuthorization(_ handler: @escaping(CLAuthorizationStatus)->Void) {
        
        locationAuthHandler = handler
        locationManager.requestAlwaysAuthorization()
    }
    
    func isValidStatus(_ status: CLAuthorizationStatus) -> Bool  {
        return (status == CLAuthorizationStatus.authorizedAlways) || (status == CLAuthorizationStatus.authorizedWhenInUse)
    }
    
    func startManager(type: NSLocationFetchType) {
        guard isValidStatus(CLLocationManager.authorizationStatus()) else {
            return
        }
        
        stopManager()
        self.fetchType = type
        locationManager.desiredAccuracy = self.fetchType == .continuous ? kCLLocationAccuracyBestForNavigation : kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
    
    public func authorized() -> Bool {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            return true
        case .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
    
    public func alwaysAuthorization (_ callBackAuthorization: ((Bool) -> (Void))?) {
        self.callBackAlwaysAuthorization = callBackAuthorization
    }
    
    func startUpdatingHeading() {
        locationManager.startUpdatingHeading()
    }
    
    func stopManager() {
        locationManager.stopUpdatingLocation()
    }
    
    func stopUpdateHeading() {
        locationManager.stopUpdatingHeading()
    }
    
    func currentPosition() -> CLLocation {
        return bestFitLocation
    }
    
}

extension LocationTracking: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let handler = locationAuthHandler {
            handler(status)
            
            var locationServicesEnabled = false
            
            switch status {
                
            case CLAuthorizationStatus.restricted: break
            case CLAuthorizationStatus.denied: break
            case CLAuthorizationStatus.notDetermined: break
                
            default:
                locationServicesEnabled = true
            }
            
            callBackAlwaysAuthorization?(locationServicesEnabled)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            let timestamp = -location.timestamp.timeIntervalSinceNow
            guard timestamp  < 5 else {
                continue
            }
            
            guard location.horizontalAccuracy > 0, location.horizontalAccuracy < 100 else {
                continue
            }
            
            bestFitLocation = location
            
        }
        
        onLocationUpdate(location: bestFitLocation)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading){
        if newHeading.headingAccuracy > 0 {
            
            self.currentHeading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
            //DDLogDebug("Heading updates to \(self.currentHeading)")
            //print("Heading upd    ates to \(self.currentHeading)")
        } else {
            //DDLogError("Error occured while updating heading")
        }
    }
    //MARK:- Distance Calculation and API update
    func onLocationUpdate(location: CLLocation) {
        
        SocketHelper.shared.emit(["location_event": location.description, "batteryLevel": UIDevice.current.batteryLevel.description])
        print("location here \(location)")
    }
}
