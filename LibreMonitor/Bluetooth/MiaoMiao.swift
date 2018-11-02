//
//  MiaoMiao.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 02.11.18.
//  Copyright © 2018 Uwe Petersen. All rights reserved.
//

import Foundation

struct MiaoMiao {
    // hardware number
    let hardwareNumber: String
    // software number
    let softwareNumber: String
    // battery level, percentage between 0 % and 100 %
    let battery: Double
    // battery level String
    let batteryString: String
    
    init(hardwareNumber: String, softwareNumber: String, battery: Double) {
        self.hardwareNumber = hardwareNumber
        self.softwareNumber = softwareNumber
        self.battery = battery
        self.batteryString = "\(Int(battery)) %"
    }
}
