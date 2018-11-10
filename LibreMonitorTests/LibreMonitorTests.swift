//
//  LibreMonitorTests.swift
//  LibreMonitorTests
//
//  Created by Uwe Petersen on 09.10.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import XCTest
@testable import LibreMonitor

class LibreMonitorTests: XCTestCase, SLIPBufferDelegate  {
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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCTAssert(2 == 2, "the message is it is false")
    }
    
    func testTransmission() {
        // Test the crc calculation for some known cases of bytes
        //
        // Original data: <9c03c8c0 1a80>
        // Excaped  data: <c0d20401 9c03c8db dc1a80cf c0> -> crc is cf as hex or -49 as Int (calculated without the c0 start and end byte)
        // Original data: <0303c810 1980>
        // Excaped  data: <c0d20401 0303c810 19801ec0> crc is 1e as hex or 30 as Int (calculated without the c0 start and end byte)
        // unescaped: <06100148 02c8c859 0018a4> -> crc is -92 (as Int)
        // escaped:   <c0c00610 014802c8 c8590018 a4c0>
        //
        // unescaped: <01200000 4e464320 4653324a 41535432 00000053>  crc is -> 83 as Int
        // excaped:   <c0012000 004e4643 20465332 4a415354 32000000 53c0>
        //
        // unescaped: <06100100 00000000 0029d0>  -> crc is -48 as Int
        // escaped:   <c0c00610 01000000 00000029 d0c0>
        
        let bytesArray: [[UInt8]] = [
            [0xB0, 0x04, 0xC8, 0xB0, 0xD7, 0x00],
            [0xCA, 0x02, 0xC8, 0x6C, 0x58, 0x01],
            [0x9D, 0x02, 0xC8, 0x98, 0x97, 0x01],
            [0x6B, 0x02, 0xC8, 0x38, 0x97, 0x00],
            [0xCA, 0x02, 0xC8, 0x6C,   0x58, 0x01, 0x9C, 0x03, 0xC8, 0xC0,  0xDB, 0xDD, 0x1A, 0x80, 0x03, 0x03, 0xC8, 0x10,   0x19, 0x80, 0x01, 0x20, 0x00, 0x00,   0x4e, 0x46, 0x43, 0x20,   0x46, 0x53, 0x32, 0x4a,   0x41, 0x53, 0x54, 0x32,   0x00, 0x00, 0x00, 0x53],
            [0xCA, 0x02, 0xC8, 0x6C,   0x58, 0x01, 0x9C, 0x03, 0xC8, 0xC0,   0xDB, 0xDD, 0xDC, 0x1A, 0x80, 0x03, 0x03, 0xC8, 0x10,   0x19, 0x80, 0x01, 0x20, 0x00, 0x00,   0x4e, 0x46, 0x43, 0x20,   0x46, 0x53, 0x32, 0x4a,   0x41, 0x53, 0x54, 0x32,   0x00, 0x00, 0x00, 0x53],
            [0xCA, 0x02, 0xC8, 0x6C,   0x58, 0x01],
            [0x9C, 0x03, 0xC8, 0xC0,   0x1A, 0x80],
            [0x03, 0x03, 0xC8, 0x10,   0x19, 0x80],
            [0x06, 0x10, 0x01, 0x48,   0x02, 0xc8, 0xc8, 0x59,   0x00, 0x18, 0xa4],
            [0x01, 0x20, 0x00, 0x00,   0x4e, 0x46, 0x43, 0x20,   0x46, 0x53, 0x32, 0x4a,   0x41, 0x53, 0x54, 0x32,   0x00, 0x00, 0x00, 0x53],
            [0x06, 0x10, 0x01, 0x00,   0x00, 0x00, 0x00, 0x00,   0x00, 0x29, 0xd0]
        ]
        
        for bytes in bytesArray {
            transmission(forPayload: bytes, packetIdentifier: UInt16(1234))
        }

        for testData in BluetoothTestData.data() {
//            let range = testData.startIndex...testData.index(testData.startIndex, offsetBy: 244) // okay values on laat: 7; 201; 253; 255; not okay values:
            let aString = testData.replacingOccurrences(of: " ", with: "")
            let bytes = stringToBytes(aString)
            transmission(forPayload: bytes, packetIdentifier: UInt16(9999))
        }
        
    }   
    
    // Delegate function for test purposes that receives the data (as received via bluetooth) and stores data in local properties
    func slipBufferReceivedPayload(_ payloadData: Data, payloadIdentifier: UInt16, txFlags: UInt8) {
        slipBufferPayloadData = payloadData
        slipBufferPayloadIdentifier = payloadIdentifier
        slipBufferTxFlags = txFlags
        print("Payload is: " + slipBufferPayloadData.debugDescription)
    }

    
    
    // Test complete transmission of a packet of bytes with SLIP, see https://de.wikipedia.org/wiki/Serial_Line_Internet_Protocol
    func transmission(forPayload payload: [UInt8], packetIdentifier: UInt16) {
        
//        // Connect simblee
//        SimbleeBLE_onConnect()
//
//        // 1. escape the payload using SLIP
//
//        let dataPayload =  Data(bytes: UnsafePointer<UInt8>(payload), count: payload.count)  // convert to NSData
//
//        let count = dataPayload.count / MemoryLayout<Int8>.size
//        var cCharArray = [CChar](repeating: 0, count: count)          // c-char array, format to be transmitted
//        (dataPayload as NSData).getBytes(&cCharArray, length: count)                  // read into the c-char array
//
//        // queue the packet and escape data if necessary according to SLIP, transmit and check for success
//        let success = UBP_queuePacketTransmission(packetIdentifier, UBP_TxFlagIsRPC, cCharArray, UInt16(payload.count))
//        XCTAssert(success, "Failed to queue packet with SLIP")
//
//        // 2. get the escaped payload as transmitted from transmission buffer
//
//        var txBuffer = [CChar](repeating: 0, count:440) /// Warning: This should not be hardcoded
//        var txBufferLength: Int32 = 0
//        getTxBuffer(&txBuffer, &txBufferLength)
//        //        let escapedDataPayload = Data(bytes: UnsafePointer<UInt8>(txBuffer), count: Int(txBufferLength))
//        let escapedDataPayload = Data(bytes: UnsafeRawPointer(txBuffer), count: Int(txBufferLength))
//
//        print("Original data: " + dataPayload.debugDescription)
//        print("Excaped  data: " + escapedDataPayload.debugDescription)
//
//        // 3. receive escaped data payload and unescape again. The unescaped data is stored in local properties
//        let slipBuffer = SLIPBuffer()
//        slipBuffer.delegate = self
//        slipBuffer.appendEscapedBytes(escapedDataPayload)
//
//        XCTAssertEqual(slipBufferPayloadData, dataPayload, "Transmitted and received payload are not equal")
//        XCTAssertEqual(slipBufferPayloadIdentifier, packetIdentifier, "Transmitted and received identifier are not equal")
//
//        // Disconnect simblee (resets the buffer)
//        SimbleeBLE_onDisconnect()
        
    }
    

    
    
    // MARK: crc test code
    
    func testCrc8() {
        // Test the crc calculation for some known cases of bytes
        //
        // Original data: <9c03c8c0 1a80>
        // Excaped  data: <c0d20401 9c03c8db dc1a80cf c0> -> crc is cf as hex or -49 as Int (calculated without the c0 start and end byte)
        // Original data: <0303c810 1980>
        // Excaped  data: <c0d20401 0303c810 19801ec0> crc is 1e as hex or 30 as Int (calculated without the c0 start and end byte)
        //
        // unescaped: <06100148 02c8c859 0018a4> -> crc is -92 (as Int)
        // escaped:   <c0c00610 014802c8 c8590018 a4c0>
        //
        // unescaped: <01200000 4e464320 4653324a 41535432 00000053>  crc is -> 83 as Int
        // excaped:   <c0012000 004e4643 20465332 4a415354 32000000 53c0>
        //
        // unescaped: <06100100 00000000 0029d0>  -> crc is -48 as Int
        // escaped:   <c0c00610 01000000 00000029 d0c0>
        
        let bytesArray: [[UInt8]] = [
            [0xd2, 0x04, 0x01, 0x9c,   0x03, 0xc8, 0xdb, 0xdc,   0x1a, 0x80, 0xcf],
            [0xd2, 0x04, 0x01, 0x03,   0x03, 0xC8, 0x10, 0x19,   0x80, 0x1e],
            [0x06, 0x10, 0x01, 0x48,   0x02, 0xc8, 0xc8, 0x59,   0x00, 0x18, 0xa4],
            [0x01, 0x20, 0x00, 0x00,   0x4e, 0x46, 0x43, 0x20,   0x46, 0x53, 0x32, 0x4a,   0x41, 0x53, 0x54, 0x32,   0x00, 0x00, 0x00, 0x53],
            [0x06, 0x10, 0x01, 0x00,   0x00, 0x00, 0x00, 0x00,   0x00, 0x29, 0xd0]
        ]
        
        for bytes in bytesArray {
            testCrc(forBytes: bytes)
            testArduinoCrc(forBytes: bytes)
        }
    }
    
    func testArduinoCrc(forBytes bytes: [UInt8])  {
        // Test an array of bytes, where the last byte contains the crc8 that should be calculated (this last byte is then the embedded crc8)
        
        var bytesToTransfer = bytes
        let bytesToTransferLength = bytes.count - 1
        
        let calculatedCrc: UInt8 = CRC8(&bytesToTransfer, UInt16(bytesToTransferLength))
        
        let embeddedCrc = bytes[bytes.count-1]
        
        
        print(String(format: "Arduino crc calculated is 0x%2x and embecced ist 0x%2x", arguments: [calculatedCrc, embeddedCrc]))
        XCTAssert(embeddedCrc == calculatedCrc, "Arduino Code: calculated and embedde crc do not match.")
    }
    
    func testCrc(forBytes bytes: [UInt8]) {
        
        // Last byte contains crc
        let PacketChecksumLength = MemoryLayout<UInt8>.size
        
        // Convert bytes to NSData
        let data = Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
        
        // Extract embedded checksum from packet
        var embeddedChecksumByte:Int8 = 0
        (data as NSData).getBytes(&embeddedChecksumByte, range: NSMakeRange(data.count - PacketChecksumLength, PacketChecksumLength))
        
        // Calculate checksum over bytes, excluding the last byte which is the embedded checksum
        let payload = Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count - PacketChecksumLength)
        let calculatedCrc8 = (payload as NSData).crc8Checksum()
        
        // Assert that they both are equal
        print(String(format: "Embedded crc8 is %d, calculated crc8 is %d", arguments: [embeddedChecksumByte, calculatedCrc8]))
        XCTAssert(embeddedChecksumByte == calculatedCrc8, "the crc8 on nsdata is false")
    }
    
    
    // MARK: example code for performance test
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
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
//            let aIndex = theString.characters.index(theString.startIndex, offsetBy: index)
//            let bIndex = theString.characters.index(theString.startIndex, offsetBy: index+2)
            let aIndex = theString.index(theString.startIndex, offsetBy: index)
            let bIndex = theString.index(theString.startIndex, offsetBy: index+2)
            let range = aIndex..<bIndex
            //            let range = Range(start: aIndex, end: bIndex)
            let string = String(theString.substring(with: range))
            let aByte = UInt8(string, radix: 16)
            theBytes.append(aByte!)
        }
        return theBytes
    }
    
}
