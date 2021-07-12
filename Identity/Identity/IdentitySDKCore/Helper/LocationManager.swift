//
//  LocationManager.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 25/06/21.
//

import Foundation
import CoreLocation

public typealias AuthorizationBlock  = (_ status: CLAuthorizationStatus) -> Void?
public typealias CompleteRequestBlock = (_ currentLocation:CLLocation?, _ error: Error?)->Void?

public class LocationManager:NSObject {
    public static let sharedInstance = LocationManager()
    public var locationManager: CLLocationManager!
    public var authorizationBlock: AuthorizationBlock?
    public var completionRequest: CompleteRequestBlock?
    var autoUpdate:Bool = false

    public override init(){
        super.init()
        initializeLocationManager()
    }
    
    /// Initialize
    fileprivate func initializeLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //let iosVersion = UIDevice.sysVersion
        //let iOS8 = iosVersion.double >= 8
        //if iOS8{
            locationManager.requestWhenInUseAuthorization() // add in plist NSLocationWhenInUseUsageDescription
        //}
        startLocationManger()
    }
    
   /// To initialize the location monitoring
   ///
   /// - Parameter completionHandler: completionHandler returns location if found.else throws error
   public func startUpdatingLocationWithCompletionHandler(_ completionHandler:((_ currentLocation:CLLocation?, _ error: Error?)->())? = nil){
        self.completionRequest = completionHandler
        startLocationManger()
    }
    public func getLocation() -> String{
        var location = ""
        if let locationManager = locationManager {
            location = "\(String(describing: locationManager.location?.coordinate.latitude ?? 0))" + "," + "\(String(describing: locationManager.location?.coordinate.longitude ?? 0))"
        }
        return location
    }
    fileprivate func startLocationManger(){
        if(autoUpdate){
            locationManager.startUpdatingLocation()
        }else{
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    fileprivate func stopLocationManger(){
        if(autoUpdate){
            locationManager.stopUpdatingLocation()
        }else{
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }

}
//Mark : - Location manager delegate methods
extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let block:AuthorizationBlock = self.authorizationBlock {
            block(status)
        }
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if(completionRequest != nil){
            completionRequest!(nil,error)
        }
    }
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        if(completionRequest != nil){
            completionRequest!(location,nil)
        }
        self.locationManager.stopUpdatingLocation()
    }
}
