//
//  LibreMonitorTestSensorData.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 28.07.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation

import XCTest
//@testable import Pods_LibreMonitor
@testable import LibreMonitor

class LibreCGMTestSensorData: XCTestCase {
    
    // Adaptions for the c-code from the arduino part
    typealias byte = UInt8
    
    // local properties for string slip Buffer content
    var slipBufferPayloadData: Data = Data()
    var slipBufferPayloadIdentifier: UInt16 = 0
    var slipBufferTxFlags: UInt8 = 0
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func arrayOfValidTestInputs() -> [[UInt8]] {
        
        var testString2 =  "FD 61 18 19 01 00 00 00"  //  0 should return "62 C2", i.e. 25282 oder 49762 (with bytes not swapped)
        testString2.append("00 00 00 00 00 00 00 00") //  1
        testString2.append("00 00 00 00 00 00 00 00") //  2
        testString2.append("62 C2 00 00 00 00 00 00") //  3
        testString2.append("00 00 00 00 00 00 00 00") //  4
        testString2.append("00 00 00 00 00 00 00 00") //  5
        testString2.append("00 00 00 00 00 00 00 00") //  6
        testString2.append("00 00 00 00 00 00 00 00") //  7
        testString2.append("00 00 00 00 00 00 00 00") //  8
        testString2.append("00 00 00 00 00 00 00 00") //  9
        testString2.append("00 00 00 00 00 00 00 00") // 10
        testString2.append("00 00 00 00 00 00 00 00") // 11
        testString2.append("00 00 00 00 00 00 00 00") // 12
        testString2.append("00 00 00 00 00 00 00 00") // 13
        testString2.append("00 00 00 00 00 00 00 00") // 14
        testString2.append("00 00 00 00 00 00 00 00") // 15
        testString2.append("00 00 00 00 00 00 00 00") // 16
        testString2.append("00 00 00 00 00 00 00 00") // 17
        testString2.append("00 00 00 00 00 00 00 00") // 18
        testString2.append("00 00 00 00 00 00 00 00") // 19
        testString2.append("00 00 00 00 00 00 00 00") // 20
        testString2.append("00 00 00 00 00 00 00 00") // 21
        testString2.append("00 00 00 00 00 00 00 00") // 22
        testString2.append("00 00 00 00 00 00 00 00") // 23
        testString2.append("00 00 00 00 00 00 00 00") // 24
        testString2.append("00 00 00 00 00 00 00 00") // 25
        testString2.append("00 00 00 00 00 00 00 00") // 26
        testString2.append("00 00 00 00 00 00 00 00") // 27
        testString2.append("00 00 00 00 00 00 00 00") // 28
        testString2.append("00 00 00 00 00 00 00 00") // 29
        testString2.append("00 00 00 00 00 00 00 00") // 30
        testString2.append("00 00 00 00 00 00 00 00") // 31
        testString2.append("00 00 00 00 00 00 00 00") // 32
        testString2.append("00 00 00 00 00 00 00 00") // 33
        testString2.append("00 00 00 00 00 00 00 00") // 34
        testString2.append("00 00 00 00 00 00 00 00") // 35
        testString2.append("00 00 00 00 00 00 00 00") // 36
        testString2.append("00 00 00 00 00 00 00 00") // 37
        testString2.append("00 00 00 00 00 00 00 00") // 38
        testString2.append("00 00 00 00 00 00 00 00") // 39
        testString2.append("58 C7 00 01 15 04 96 50") // 40
        testString2.append("14 07 96 80 5A 00 ED A6") // 41
        testString2.append("12 13 1B C8 04 99 28 66") // 42

        testString2 = testString2.replacingOccurrences(of: " ", with: "")
        let bytes2 = stringToBytes(testString2)
        
        
        var testString3 =  "90 DC 18 19 03 00 00 00"  //  0
        testString3.append("00 00 00 00 00 00 00 00") //  1
        testString3.append("00 00 00 00 00 00 00 00") //  2
        testString3.append("E1 D7 06 03 FC 04 C8 24") //  3
        testString3.append("DA 80 F1 04 C8 30 9A 80") //  4
        testString3.append("E4 04 C8 24 9A 80 D4 04") //  5
        testString3.append("C8 10 5A 80 CB 04 C8 6C") //  6
        testString3.append("9A 80 C2 04 C8 78 DA 80") //  7 "C204C878DA80" for trend test
        testString3.append("2D 05 C8 18 D9 80 2B 05") //  8
        testString3.append("88 0E D9 81 33 05 C8 2C") //  9
        testString3.append("D9 80 31 05 C8 38 D9 80") // 10
        testString3.append("31 05 C8 28 D9 80 2E 05") // 11
        testString3.append("C8 34 D9 80 2B 05 C8 98") // 12
        testString3.append("99 80 22 05 C8 C0 99 80") // 13
        testString3.append("18 05 C8 00 9A 80 0A 05") // 14
        testString3.append("C8 08 9A 80 00 00 88 06") // 15
        testString3.append("98 80 55 05 C8 2C D9 80") // 16
        testString3.append("27 05 C8 98 99 80 00 00") // 17 "2705C8989980" for history test
        testString3.append("00 00 00 00 00 00 00 00") // 18
        testString3.append("00 00 00 00 00 00 00 00") // 19
        testString3.append("00 00 00 00 00 00 00 00") // 20
        testString3.append("00 00 00 00 00 00 00 00") // 21
        testString3.append("00 00 00 00 00 00 00 00") // 22
        testString3.append("00 00 00 00 00 00 00 00") // 23
        testString3.append("00 00 00 00 00 00 00 00") // 24
        testString3.append("00 00 00 00 00 00 00 00") // 25
        testString3.append("00 00 00 00 00 00 00 00") // 26
        testString3.append("00 00 00 00 00 00 00 00") // 27
        testString3.append("00 00 00 00 00 00 00 00") // 28
        testString3.append("00 00 00 00 00 00 00 00") // 29
        testString3.append("00 00 00 00 00 00 00 00") // 30
        testString3.append("00 00 00 00 00 00 00 00") // 31
        testString3.append("00 00 00 00 00 00 00 00") // 32
        testString3.append("00 00 00 00 00 00 00 00") // 33
        testString3.append("00 00 00 00 00 00 00 00") // 34
        testString3.append("00 00 00 00 00 00 00 00") // 35
        testString3.append("00 00 00 00 00 00 00 00") // 36
        testString3.append("00 00 00 00 00 00 00 00") // 37
        testString3.append("00 00 00 00 00 00 00 00") // 38
        testString3.append("00 00 00 00 37 00 00 00") // 39
        testString3.append("58 C7 00 01 15 04 96 50") // 40
        testString3.append("14 07 96 80 5A 00 ED A6") // 41
        testString3.append("12 13 1B C8 04 99 28 66") // 42
        testString3 = testString3.replacingOccurrences(of: " ", with: "")
        let bytes3 = stringToBytes(testString3)
        
        return [bytes2, bytes3]
    }
    
    func testCrcTable() {
        
    }
    
    func testExample() {
        
        // Test valid crc and other data for the test cases
        print("------- valid test cases for crc and other ------")
        let validTestCaseBytes = arrayOfValidTestInputs().last!
        let date = Date()
        if let sensorData = SensorData(bytes: validTestCaseBytes, date: date) {
            print(sensorData)
            print("Header validity: " + String(sensorData.hasValidHeaderCRC))
            print("Body validity:" + String(sensorData.hasValidBodyCRC))
            
            XCTAssert(sensorData.hasValidHeaderCRC == true, "Unvalid header crc")
            XCTAssert(sensorData.hasValidBodyCRC == true, "Unvalid body crc")
            XCTAssert(sensorData.hasValidFooterCRC == true, "Unvalid footer crc")
            
            XCTAssert(sensorData.minutesSinceStart == 55, "Wrong minutesSinceStart counter")
            XCTAssert(sensorData.nextTrendBlock == 6, "Wrong next trend block")
            XCTAssert(sensorData.nextHistoryBlock == 3, "Wrong next history block")
            XCTAssert(sensorData.date == date, "Wrong date")
            XCTAssert(sensorData.state == .ready, "Wrong sensor state")
            
            // Test trend glucose measurement
            let trendMeasurements = sensorData.trendMeasurements(0.0, slope: 0.1)
            XCTAssert(trendMeasurements.count == 16, "Wrong number of trend measurements")
            let byteStringInTrendMeasurement = trendMeasurements[0].byteString
            let byteTrendStringAsReadFromSensor = "C204C878DA80"
            XCTAssert(byteStringInTrendMeasurement == byteTrendStringAsReadFromSensor, "Wrong byte string") // "[194, 4, 200, 120, 218, 128]" or "C204C878DA80"
            XCTAssert(trendMeasurements[0].date == date, "Wrong date")
            XCTAssert(trendMeasurements[0].rawValue == 1218, "Wrong raw value")
            XCTAssert((trendMeasurements[0].glucose - 121.8) < 0.001, "Wrong glucose value")
            
            // Test count and byte strings of history glucose measurement
            let historyMeasurements = sensorData.historyMeasurements(0.0, slope: 0.1)
            XCTAssert(historyMeasurements.count == 32, "Wrong number of history measurements")
            let byteStringInHistoryMeasurement = historyMeasurements[0].byteString
            let byteHIstoryStringAsReadFromSensor = "2705C8989980"
            XCTAssert(byteStringInHistoryMeasurement == byteHIstoryStringAsReadFromSensor, "Wrong byte string") // "[194, 4, 200, 120, 218, 128]" or "C204C878DA80"
            
            
            // Test dates of history glucose measurements. Date of most recent value must be 10 minutes behind and date of second most recent value must be 10 + 15 = 25 minutes behind
            let tenMintues = 10 * 60
            let twentyFiveMintues = 25 * 60
            XCTAssert( Int(round(date.timeIntervalSince(historyMeasurements[0].date))) == tenMintues, "Wrong history date, not 10 minutes apart")
            XCTAssert( Int(round(date.timeIntervalSince(historyMeasurements[1].date))) == twentyFiveMintues, "Wrong history date, not 25 minutes apart")

            // Test raw values and glucose values of history measurements
            XCTAssert(historyMeasurements[0].rawValue == 1319, "Wrong raw value")
            XCTAssert((historyMeasurements[0].glucose - 131.9) < 0.001, "Wrong glucose value")

        }
        
        // change data of body and ensure that crc is now different
        print("------- invalid test cases for crc ------")
        var invalidTestCaseBytes = validTestCaseBytes
        let endIndex = invalidTestCaseBytes.endIndex-1
        invalidTestCaseBytes[endIndex] = invalidTestCaseBytes[endIndex] | 0xff  // change data such that crc will not match any more
        if let sensorData = SensorData(bytes: invalidTestCaseBytes, date: Date()) {
            print(sensorData)
            print("Header validity: " + String(sensorData.hasValidHeaderCRC))
            
            XCTAssertFalse(sensorData.hasValidFooterCRC == true, "Error in footer crc")
        }
    }
    
    
    
    func stringToBytes(_ theString: String) -> [UInt8] {
        
        let length = theString.lengthOfBytes(using: String.Encoding.utf8)
        guard length % 2 == 0 else {
            print("Error in \(#function): String does not have an even number of characters and is thus not a valid string of pairs of characters where each pair represents a byte.")
            return [0]
        }
        
        var theBytes = [UInt8]()
        for index in stride(from: 0, to: length, by: 2) {
            let aIndex = theString.characters.index(theString.startIndex, offsetBy: index)
            let bIndex = theString.characters.index(theString.startIndex, offsetBy: index+2)
            let range = aIndex..<bIndex
//            let range = Range(start: aIndex, end: bIndex)
            let string = String(theString.substring(with: range))
            let aByte = UInt8(string!, radix: 16)
            theBytes.append(aByte!)
        }
        return theBytes
    }
    
}
