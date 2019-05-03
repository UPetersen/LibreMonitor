//
//  LibreUtils.swift
//  SwitftOOPWeb
//
//  Created by Bjørn Inge Berg on 14.10.2018.
//  Copyright © 2018 Bjørn Inge Berg. All rights reserved.
//

import Foundation



class LibreUtils {
    
    public static var accessToken: String = "someaccesstoken"
   
    public static func CreateFakePatch(fromPatch patch:[UInt8]=LibreOOPDefaults.TestPatchAlwaysReturning63, raw_glucose: UInt16?=nil, raw_temp: UInt16?=nil) -> [UInt8]{
        
        //glucoseByte2,glucoseByte1, flag1, tempByte2, tempByte1, flag2
        var value: [UInt8] = [0xff, 0x3f, 0xc8, 0xfc, 0xd8, 0x00]
        
        if let raw_glucose = raw_glucose {
            value[0] = UInt8(raw_glucose & 0xFF)
            value[1] = UInt8(raw_glucose >> 8)
        }
        if let raw_temp = raw_temp {
            value[3] = UInt8(raw_temp & 0xFF)
            value[4] = UInt8(raw_temp >> 8)
            
        }
      
        
        
        var modifiedPatch = Array(patch[0..<24])
        modifiedPatch += patch[24..<28]  // first four bytes of body from original patch (crc and index on trend and history values)
        for _ in 1...48 {
            modifiedPatch += value // always the same data
        }
        modifiedPatch += patch[316..<320] // Rest of data (minute counter and two zeros.)
        modifiedPatch += patch[320..<344] // footer
        
        // 2018-11-03: Uwe: fake uuid
        return SensorData(uuid: Data([0x00]), bytes: modifiedPatch)!.bytesWithCorrectCRC()
//        return SensorData(uuid: Data(bytes: [0x00]), bytes: modifiedPatch)!.bytesWithCorrectCRC()
//        return SensorData(bytes: modifiedPatch)!.bytesWithCorrectCRC()
        
    }
    
    public static func GetParsedOOPResult(patch: [UInt8]) -> OOPCurrentValue? {
        let client = LibreOOPClient(accessToken: self.accessToken)
        var result : OOPCurrentValue? = nil
        let awaiter = DispatchSemaphore(value: 0)
        
        client.uploadReading(reading: patch ) { (response, success, errormessage) in
            if(!success) {
                NSLog("remote: upload reading failed! \(errormessage)")
                print("getparsedresult signal because of error")
                awaiter.signal()
                return
            }
            
            if let response = response, let uuid = response.result?.uuid {
                print("uuid received: " + uuid)
                client.getStatusIntervalled(uuid: uuid, { (success, errormessage, oopCurrentValue, newState) in
                    
                    NSLog("GetStatusIntervalled returned with success?: \(success), error: \(errormessage), response: \(String(describing: oopCurrentValue))), newState: \(newState)")
                    NSLog("GetStatusIntervalled  newState: \(newState)")
                    
                    result = oopCurrentValue
                    
                    print("getparsedresult signal")
                    awaiter.signal()
                    
                })
            } else {
                print("getparsedresult signal")
                awaiter.signal()
            }
            
            
        }
        print("awaiting getparsedresult")
        awaiter.wait()

        return result
    }

    public static func GetParsedOOPResultAsync(patch: [UInt8]) -> OOPCurrentValue? {
        let client = LibreOOPClient(accessToken: self.accessToken)
        var result : OOPCurrentValue? = nil
//        let awaiter = DispatchSemaphore(value: 0)
        
        client.uploadReading(reading: patch ) { (response, success, errormessage) in
            if(!success) {
                NSLog("remote: upload reading failed! \(errormessage)")
                print("getparsedresult signal because of error")
//                awaiter.signal()
                return
            }
            
            if let response = response, let uuid = response.result?.uuid {
                print("uuid received: " + uuid)
                client.getStatusIntervalled(uuid: uuid, { (success, errormessage, oopCurrentValue, newState) in
                    
                    NSLog("GetStatusIntervalled returned with success?: \(success), error: \(errormessage), response: \(String(describing: oopCurrentValue))), newState: \(newState)")
                    NSLog("GetStatusIntervalled  newState: \(newState)")
                    
                    result = oopCurrentValue
                    
                    print("getparsedresult signal")
//                    awaiter.signal()
                    
                })
            } else {
                print("getparsedresult signal")
//                awaiter.signal()
            }
            
            
        }
        print("awaiting getparsedresult")
//        awaiter.wait()
        
        return result
    }

    
    
}
