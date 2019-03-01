////
////  TheSensor.swift
////  LibreMonitor
////
////  Created by Uwe Petersen on 02.12.18.
////  Copyright © 2018 Uwe Petersen. All rights reserved.
////
//
//import Foundation
//
//
//
///// Structure for data from Freestyle Libre sensor
///// To be initialized with the bytes as read via nfc. Provides all derived data.
//
//
//struct TheSensorData {
//
//    /// Parameters for the temperature compensation algorithm
////    let temperatureAlgorithmParameterSet: TemperatureAlgorithmParameters?
//
//    /// The uid of the sensor
//    let uuid: Data
//
//    /// The serial number of the sensor
//    let serialNumber: String
//
//    /// (Fixed) number of bytes of sensor data to be used (read only), i.e. 344 bytes (24 for header, 296 for body and 24 for footer)
//    private let numberOfBytes = 344 // Header and body and footer of Freestyle Libre data (i.e. 40 blocks of 8 bytes)
//
//    /// Array of 344 bytes as read via nfc
//    let bytes: [UInt8]
//
//    /// Subarray of 24 header bytes
//    let header: [UInt8]
//
//    /// Subarray of 296 body bytes
//    let body: [UInt8]
//
//    /// Subarray of 24 footer bytes
//    let footer: [UInt8]
//
//    /// Date when data was read from sensor
//    let date: Date
//
//    /// Minutes (approx) since start of sensor
//    let minutesSinceStart: Int
//
//    /// Index on the next block of trend data that the sensor will measure and store
//    let nextTrendGlucoseRecord: Int
//
//    /// Index on the next block of history data that the sensor will create from trend data and store
//    let nextHistoryGlucoseRecord: Int
//
//    /// true if all crc's are valid
//    var hasValidCRCs: Bool {
//        return hasValidHeaderCRC && hasValidBodyCRC && hasValidFooterCRC
//    }
//
//    /// true if the header crc, stored in the first two header bytes, is equal to the calculated crc
//    var hasValidHeaderCRC: Bool
//
//    /// true if the body crc, stored in the first two body bytes, is equal to the calculated crc
//    var hasValidBodyCRC: Bool
//
//    /// true if the footer crc, stored in the first two footer bytes, is equal to the calculated crc
//    var hasValidFooterCRC: Bool
//
//    /// Footer crc needed for checking integrity of SwiftLibreOOPWeb response
//    var footerCrc: UInt16
//
//    /// Array with the 16 trend glucose records
//    var trendGlucoseRecords: [GlucoseRecord]
//
//    /// Array with the 32 history glucose records
//    var historyGlucoseRecords: [GlucoseRecord]
//
//    /// Sensor state (ready, failure, starting etc.)
//    var state: SensorState
//
//    init?(uuid: Data, bytes: [UInt8], date: Date = Date()) {
//
//        self.date = date
//
//        guard bytes.count == numberOfBytes else {
//            return nil
//        }
//        self.bytes = bytes
//
//        self.uuid = uuid
//        self.serialNumber = SensorSerialNumber(withUID: uuid)?.serialNumber ?? "-"
//
//        self.header = Array(bytes[0..<24])    //  24 bytes, i.e.  3 blocks a 8 bytes
//        self.body   = Array(bytes[24..<320])  // 296 bytes, i.e. 37 blocks a 8 bytes
//        self.footer = Array(bytes[320..<344]) //  24 bytes, i.e.  3 blocks a 8 bytes
//
//        self.hasValidHeaderCRC = Crc.hasValidCrc16InFirstTwoBytes(header)
//        self.hasValidBodyCRC = Crc.hasValidCrc16InFirstTwoBytes(body)
//        self.hasValidFooterCRC = Crc.hasValidCrc16InFirstTwoBytes(footer)
//
//        self.footerCrc = Crc.crc16(Array(footer.dropFirst(2)), seed: 0xffff)
//
//        self.state = SensorState(stateByte: header[4])
//
//        self.nextTrendGlucoseRecord = Int(body[2])
//        self.nextHistoryGlucoseRecord = Int(body[3])
//        self.minutesSinceStart = Int(body[293]) << 8 + Int(body[292])
//
//        self.trendGlucoseRecords = GlucoseRecord.glucoseRecords(date: self.date, bytes: Array(body[4..<100]), nextRecord: nextTrendGlucoseRecord, timeIntervalBetweenDates: 60.0)
//
//        let (aDate, _) = TheSensorData.dateOfMostRecentHistoryValue(date: self.date, nextHistoryGlucoseRecord: nextHistoryGlucoseRecord, minutesSinceStart: minutesSinceStart)
//        self.historyGlucoseRecords = GlucoseRecord.glucoseRecords(date: aDate, bytes: Array(body[100..<292]), nextRecord: nextHistoryGlucoseRecord, timeIntervalBetweenDates: 15.0*60.0)
//
//    }
//
//
//    /// Get date of most recent history value.
//    /// History values are updated every 15 minutes. Their corresponding time from start of the sensor in minutes is 15, 30, 45, 60, ..., but the value is delivered three minutes later, i.e. at the minutes 18, 33, 48, 63, ... and so on. So for instance if the current time in minutes (since start of sensor) is 67, the most recent value is 7 minutes old. This can be calculated from the minutes since start. Unfortunately sometimes the history index is incremented earlier than the minutes counter and they are not in sync. This is also taken care of.
//    ///
//    /// - Parameters:
//    ///   - date: date when the sensor was read
//    ///   - nextHistoryGlucoseRecord: pointer on the next history record of FRAM that data will be written to
//    ///   - minutesSinceStart: minute counter of the FRAM
//    /// - Returns: the date of the most recent history value and the corresponding minute counter
//    static func dateOfMostRecentHistoryValue(date: Date, nextHistoryGlucoseRecord: Int, minutesSinceStart: Int) -> (date: Date, counter: Int) {
//        // Calculate correct date for the most recent history value.
//        //        date.addingTimeInterval( 60.0 * -Double( (minutesSinceStart - 3) % 15 + 3 ) )
//        let nextHistoryIndexCalculatedFromMinutesCounter = ( (minutesSinceStart - 3) / 15 ) % 32
//        let delay = (minutesSinceStart - 3) % 15 + 3 // in minutes
//        if nextHistoryIndexCalculatedFromMinutesCounter == nextHistoryGlucoseRecord {
//            // Case when history index is incremented togehter with minutesSinceStart (in sync)
//            //            print("delay: \(delay), minutesSinceStart: \(minutesSinceStart), result: \(minutesSinceStart-delay)")
//            return (date: date.addingTimeInterval( 60.0 * -Double(delay) ), counter: minutesSinceStart - delay)
//        } else {
//            // Case when history index is incremented before minutesSinceStart (and they are async)
//            //            print("delay: \(delay), minutesSinceStart: \(minutesSinceStart), result: \(minutesSinceStart-delay-15)")
//            return (date: date.addingTimeInterval( 60.0 * -Double(delay - 15)), counter: minutesSinceStart - delay)
//        }
//    }
//
//    func oopWebInterfaceInput() -> String {
//        return Data(bytes).base64EncodedString()
//    }
//
//    /// Returns a new array of 344 bytes of FRAM with correct crc for header, body and footer.
//    ///
//    /// Usefull, if some bytes are modified in order to investigate how the OOP algorithm handles this modification.
//    /// - Returns: 344 bytes of FRAM with correct crcs
//    func bytesWithCorrectCRC() -> [UInt8] {
//        return Crc.bytesWithCorrectCRC(header) + Crc.bytesWithCorrectCRC(body) + Crc.bytesWithCorrectCRC(footer)
//    }
//
//
//}
//
