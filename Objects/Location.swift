//
//  Location.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 01/04/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import Foundation
import CoreLocation

class Location {
    var distance : CLLocationDistance
    var location : CLLocation
    var locTitle : String
    
    init(distance : CLLocationDistance, location : CLLocation, locTitle : String) {
        self.distance = distance
        self.locTitle = locTitle
        self.location = location
    }
}
