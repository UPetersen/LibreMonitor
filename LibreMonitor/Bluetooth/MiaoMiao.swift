//
//  MiaoMiao.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 02.11.18.
//  Copyright © 2018 Uwe Petersen. All rights reserved.
//

import Foundation

struct MiaoMiao: CustomStringConvertible {
    // hardware number
    let hardware: String
    // software number
    let firmware: String
    // battery level, percentage between 0 % and 100 %
    let battery: Int
    // battery level String
    let batteryString: String
    
    init(hardware: String, firmware: String, battery: Int) {
        self.hardware = hardware
        self.firmware = firmware
        self.battery = battery
        self.batteryString = "\(battery) %"
    }
    
    var description: String {
        return "Hardware: \(hardware), firmware: \(firmware), battery: \(batteryString)"
    }
}
