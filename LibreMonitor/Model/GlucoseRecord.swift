//
//  GlucoseRecord.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 08.12.18.
//  Copyright © 2018 Uwe Petersen. All rights reserved.
//

import Foundation

/// Structure for one glucose record including value, date and raw data bytes.
struct GlucoseRecord {
    
    /// The date for this glucose record.
    let date: Date
    
    /// The minute counter for this glucose record.
    let counter: Int
    
    /// The bytes of the glucose record as read from the sensor. All data is derived from this \"raw data".
    let bytes: [UInt8]
    
    /// The bytes of the glucose record as string.
    let byteString: String
    
    /// The raw glucose as read from the sensor.
    let rawGlucose: Int
    
    /// The raw temperature as read from the sensor.
    let rawTemperature: Int
    
    /// Slope to calculate glucose from raw value in (mg/dl)/raw.
    let slope: Double
    
    /// Glucose offset to be added in mg/dl.
    let offset: Double
    
    /// The glucose value in mg/dl using the simple algorithm with offset and slope.
    ///
    ///    glucose = slope * rawGlucose + offset.
    let glucose: Double
    
    /// Glucose calculated using the temperarure compensation algorithm.
    let temperatureAlgorithmGlucose: Double
    // {"status":"complete","slope_slope":0.00001816666666666667,"slope_offset":-0.00016666666666666666,"offset_offset":-21.5,"offset_slope":0.007499999999999993,"uuid":"calibrationmetadata-e61686dd-1305-44f0-a675-df98aabce67f","isValidForFooterWithReverseCRCs":61141}
    //    let slope_slope = 1.7333333333333336e-05
    //    let slope_offset = -0.0006666666666666666
    //    let offset_slope = 0.0049999999999999906
    //    let offset_offset = -19.0
    
    //    let slope_slope = 0.00001816666666666667
    //    let slope_offset = -0.00016666666666666666
    //    let offset_slope = 0.007499999999999993
    //    let offset_offset = -21.5
    /// The Glucose offset to be added in mg/dl. This offset was calculated from the raw temperature using the temperature compensation algorithm.
    let temperatureCompensatedOffset: Double

    /// The slope used to mulitply the raw glucse with. This slope was calculated from the raw temperature using the temperature compensation algorithm.
    let temperatureCompensatedSlope: Double

    /// 
    let temperatureAlgorithmParameterSet: TemperatureAlgorithmParameters?
    
    
    ///
    /// - parameter bytes:  raw data bytes as read from the sensor
    /// - parameter slope:  slope to calculate glucose from raw value in (mg/dl)/raw
    /// - parameter offset: glucose offset to be added in mg/dl
    /// - parameter date:   date of the GlucoseRecord
    ///
    /// - returns: GlucoseRecord
    init(bytes: [UInt8], slope: Double = 0.1, offset: Double = 0.0, counter: Int = 0, date: Date, derivedAlgorithmParameterSet: TemperatureAlgorithmParameters? = nil) {
        self.bytes = bytes
        self.byteString = bytes.reduce("", {$0 + String(format: "%02X", arguments: [$1])})
        self.rawGlucose = (Int(bytes[1] & 0x1F) << 8) + Int(bytes[0]) // switched to 13 bit mask on 2018-03-15
        self.rawTemperature = (Int(bytes[4] & 0x3F) << 8)  + Int(bytes[3]) // 14 bit-mask for raw temperature
        self.slope = slope
        self.offset = offset
        self.glucose = offset + slope * Double(rawGlucose)
        self.date = date
        self.counter = counter
        
        //        self.oopSlope = slope_slope * Double(rawTemperature) + offset_slope
        //        self.oopOffset = slope_offset * Double(rawTemperature) + offset_offset
        //        self.oopGlucose = oopSlope * Double(rawGlucose) + oopOffset
        
        self.temperatureAlgorithmParameterSet = derivedAlgorithmParameterSet
        if let derivedAlgorithmParameterSet = self.temperatureAlgorithmParameterSet {
            self.temperatureCompensatedOffset = derivedAlgorithmParameterSet.slope_slope * Double(rawTemperature) + derivedAlgorithmParameterSet.offset_slope
            self.temperatureCompensatedSlope = derivedAlgorithmParameterSet.slope_offset * Double(rawTemperature) + derivedAlgorithmParameterSet.offset_offset
            //        self.oopSlope = slope_slope * Double(rawTemperature) + slope_offset
            //        self.oopOffset = offset_slope * Double(rawTemperature) + offset_offset
            let oopGlucose = temperatureCompensatedOffset * Double(rawGlucose) + temperatureCompensatedSlope
            // Final correction, if sensor values are very low and need to be compensated
            self.temperatureAlgorithmGlucose = oopGlucose * derivedAlgorithmParameterSet.additionalSlope + derivedAlgorithmParameterSet.additionalOffset
        } else {
            self.temperatureCompensatedOffset = 0
            self.temperatureCompensatedSlope = 0
            self.temperatureAlgorithmGlucose = 0
        }
        
        print(self.description)
    }
    
    
    /// Get array of 16 trend glucose measurements.
    /// Each array is sorted such that the most recent value is at index 0 and corresponds to the time when the sensor was read, i.e. self.date. The following measurements are each one more minute behind, i.e. -1 minute, -2 mintes, -3 minutes, ... -15 minutes.
    ///
    /// - parameter offset: offset in mg/dl that is added
    /// - parameter slope:  slope in (mg/dl)/ raw
    ///
    /// - returns: Array of Measurements
    static func glucoseRecords(date: Date, bytes: [UInt8], nextRecord: Int, timeIntervalBetweenDates: TimeInterval) -> [GlucoseRecord] {
        var glucoseRecords = [GlucoseRecord]()
        // Trend data is stored in body from byte 4 to byte 4+96=100 in units of 6 bytes. Index on data such that most recent block is first.
        for recordIndex in 0...(bytes.count/6) {
            var byteIndex = (nextRecord - 1 - recordIndex) * 6 // runs backwards
            if byteIndex < 0 {
                byteIndex = byteIndex + 96 // if end of ring buffer is reached shift to beginning of ring buffer
            }
            let range = byteIndex..<byteIndex+6
            let glucoseRecordBytes = Array(bytes[range])
            let glucoseRecordDate = date.addingTimeInterval(-timeIntervalBetweenDates * TimeInterval(recordIndex))
            glucoseRecords.append(GlucoseRecord(bytes: glucoseRecordBytes,  date: glucoseRecordDate))
        }
        return glucoseRecords
    }
    
    
    var description: String {
        var aString = String("Glucose: \(glucose) (mg/dl), date:  \(date), slope: \(slope), offset: \(offset), rawGlucose: \(rawGlucose), rawTemperature: \(rawTemperature), bytes: \(bytes) \n")
        aString.append("OOP: slope_slope: \(String(describing: temperatureAlgorithmParameterSet?.slope_slope)), slope_offset: \(String(describing: temperatureAlgorithmParameterSet?.slope_offset)), offset_slope: \(String(describing: temperatureAlgorithmParameterSet?.offset_slope)), offset_offset: \(String(describing: temperatureAlgorithmParameterSet?.offset_offset))\n")
        aString.append("OOP: slope: \(temperatureCompensatedOffset), \noffset: \(temperatureCompensatedSlope)")
        
        return aString
        //        return String("Glucose: \(glucose) (mg/dl), date:  \(date), slope: \(slope), offset: \(offset), rawGlucose: \(rawGlucose), rawTemperature: \(rawTemperature), bytes: \(bytes)  /n oop: slope_slope = " )
    }
}
