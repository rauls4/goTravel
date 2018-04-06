//
//  Manager.swift
//  Memory
//
//  Created by Raul Silva on 2/17/18.
//  Copyright © 2018 Silva. All rights reserved.
//

import Foundation
import CoreLocation

final class Manager {               //Singleton
    private init() { }
    static let shared = Manager()
    let locationManager = CLLocationManager()
}
