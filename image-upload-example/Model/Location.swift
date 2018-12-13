//
//  Location.swift
//  image-upload-example
//
//  Created by Peter Keller on 12/9/18.
//  Copyright © 2018 Peter Keller. All rights reserved.
//

import CoreLocation

class Location {
    static var sharedInstance = Location()
    private init() {}
    
    var latitude: Double!
    var longitude: Double!
    var address: String!
    
    static func formatAddress (pm: CLPlacemark) -> String {
        var address = ""
        let subThoroughfare = pm.subThoroughfare ?? ""
        let thoroughfare = pm.thoroughfare ?? ""
        let locality = pm.locality ?? ""
        if subThoroughfare.count > 0 {
            address = subThoroughfare + " "
        }
        if thoroughfare.count > 0 {
            address = address + thoroughfare
        }
        if locality.count > 0 {
            if address.count > 0 {
                address = address + ", "
            }
            address = address + locality
        }
        return address;
    }
    
}
