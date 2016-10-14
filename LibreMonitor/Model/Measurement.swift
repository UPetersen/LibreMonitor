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
        self.rawValue = (Int(bytes[1]) << 8) & 0x0F00 + Int(bytes[0])
        self.slope = slope
        self.offset = offset
        self.glucose = offset + slope * Double(rawValue)
        self.date = date
    }
    var description: String {
        return String("Glucose: \(glucose) (mg/dl), date:  \(date), slope: \(slope), offset: \(offset),rawValue: \(rawValue), bytes: \(bytes)" )
    }
}
