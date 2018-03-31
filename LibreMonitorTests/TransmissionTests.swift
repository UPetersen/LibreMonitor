//
//  TransmissionTests.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 03.02.17.
//  Copyright © 2017 Uwe Petersen. All rights reserved.
//

import Foundation

import XCTest
//@testable import Pods_LibreMonitor
@testable import LibreMonitor

class TransmissionTests: XCTestCase {

    
    var testData = [[UInt8]]()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
        guard let _ = BluetoothTestData.data().last else {
            return
        }
        

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    func testTransmission() {
        
    }
    
    
    
    func stringToBytes(_ theString: String) -> [UInt8] {
        
        let length = theString.lengthOfBytes(using: String.Encoding.utf8)
        guard length % 2 == 0 else {
            print("Error in \(#function): String does not have an even number of characters and is thus not a valid string of pairs of characters where each pair represents a byte.")
            return [0]
        }
        
        var theBytes = [UInt8]()
        for index in stride(from: 0, to: length, by: 2) {
//            let aIndex = theString.characters.index(theString.startIndex, offsetBy: index)
//            let bIndex = theString.characters.index(theString.startIndex, offsetBy: index+2)
            let aIndex = theString.index(theString.startIndex, offsetBy: index)
            let bIndex = theString.index(theString.startIndex, offsetBy: index+2)
            let range = aIndex..<bIndex
            //            let range = Range(start: aIndex, end: bIndex)
//            let string = String(theString.substring(with: range))
            let string = String(theString[range])
            let aByte = UInt8(string, radix: 16)
            theBytes.append(aByte!)
        }
        return theBytes
    }
    

}
