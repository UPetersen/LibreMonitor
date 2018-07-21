//
//  Measurement.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 25.08.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation


/// Structure for one glucose measurement including value, date and raw data bytes
struct Measurement {
    /// The date for this measurement
    let date: Date
    /// The bytes as read from the sensor. All data is derived from this \"raw data"
    let bytes: [UInt8]
    /// The bytes as String
    let byteString: String
    /// The raw value as read from the sensor
    let rawValue: Int
    /// slope to calculate glucose from raw value in (mg/dl)/raw
    let slope: Double
    /// glucose offset to be added in mg/dl
    let offset: Double
    /// The glucose value in mg/dl
    let glucose: Double
    /// Initialize a new glucose measurement
    ///
    /// - parameter bytes:  raw data bytes as read from the sensor
    /// - parameter slope:  slope to calculate glucose from raw value in (mg/dl)/raw
    /// - parameter offset: glucose offset to be added in mg/dl
    /// - parameter date:   date of the measurement
    ///
    /// - returns: Measurement
    init(bytes: [UInt8], slope: Double = 0.1, offset: Double = 0.0, date: Date) {
        self.bytes = bytes
        self.byteString = bytes.reduce("", {$0 + String(format: "%02X", arguments: [$1])})
        self.rawValue = (Int(bytes[1]) << 8) & 0x1F00 + Int(bytes[0]) // switched to 13 bit mask on 2018-03-15
        self.slope = slope
        self.offset = offset
        self.glucose = offset + slope * Double(rawValue)
        self.date = date
    }
    
    func temp1() -> Double {
        let anInt = (Int(self.bytes[4] & 0x3F) << 8) + Int(self.bytes[5])
        return 0.5 * (-273.16 + sqrt(abs(273.16*273.16 + 4.0 * Double(anInt))))
    }
    func temp2() -> Double {
        let anInt = (Int(self.bytes[4] & 0x3F) << 8) + Int(self.bytes[3])
        return 0.5 * (-273.16 + sqrt(abs(273.16*273.16 + 4.0 * Double(anInt))))
    }
    
    // Gitter
    func temp3() -> Double {
        let anInt = (Int(self.bytes[4] & 0x3F) << 8) + Int(self.bytes[5])
        return 22.22 * log(311301.0/(11.44 * Double(anInt)))
    }
    //Pierre Vandevenne 1
    func temp4() -> Double {
        let anInt = 16384 - (Int(self.bytes[4] & 0x3F) << 8) + Int(self.bytes[5])
        
        let a = 1.0
        let b = 273.0
        let c = -Double(anInt)
        let d = (b*b) - (4*a*c)
        let res = -b + sqrt( d ) / (2*a)
        return  abs(res*0.0027689+9.53)
    }

    // Pierre Vandevenne 2
    func temp5() -> Double {
        let anInt = 16383 - (Int(self.bytes[4] & 0x3F) << 8) + Int(self.bytes[5])
        return  abs(Double(anInt)*0.0027689+9.53)
    }
    
    
//    Temp = 22.22 * log(311301/NTC)
    
    var description: String {
        return String("Glucose: \(glucose) (mg/dl), date:  \(date), slope: \(slope), offset: \(offset),rawValue: \(rawValue), bytes: \(bytes)" )
    }
}
