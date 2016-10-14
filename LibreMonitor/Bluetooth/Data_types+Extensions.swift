//
//  Data_types+Extensions.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 15.05.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation

extension IDNDataType {
    
    func deviceIDString() -> String {
        
        var _self = self  // make a copy of self to be able to access it via a pointer (does not work on self itself)
        
        // Extrakt device ID by creating an array from the tuple
        
        let deviceIDString = withUnsafePointer(to: &_self.deviceID, { (ptr) -> String? in
            
            let uint8Ptr = unsafeBitCast(ptr, to: UnsafePointer<UInt8>.self)
            
            var deviceIDString: String = String(format: "%02X", arguments: [uint8Ptr[0]])
            for index in 1...12 {
                deviceIDString += String(format: ":%02X", arguments: [uint8Ptr[index]])
            }
            return deviceIDString
        })
        
        print(deviceIDString!)
        
        return deviceIDString ?? "no device id"
    }
}


extension SystemInformationDataType {
    
    func uidString() -> String {
        
        var _self = self  // make a copy of self to be able to access it via a pointer (does not work on self itself)
        
        // Extrakt UID by creating an array from the tuple
        
        let uidString = withUnsafePointer(to: &_self.uid, { (ptr) -> String? in
            
            let uint8Ptr = unsafeBitCast(ptr, to: UnsafePointer<UInt8>.self)
            
            var uidString: String = String(format: "%02X", arguments: [uint8Ptr[0]])
            for index in 1...7 {
                uidString += String(format: "%02X", arguments: [uint8Ptr[index]])
//                uidString += String(format: ":%02X", arguments: [uint8Ptr[index]])
            }
            return uidString
        })
        
        print(uidString!)
        
        return uidString ?? "no uid"
    }
}


//extension RawDataType {
//    func byteString() -> String {
//        
//        var _self = self  // make a copy of self to be able to access it via a pointer (does not work on self itself)
//        
//        // Extrakt UID by creating an array from the tuple
//        
//        let byteString = withUnsafePointer(&_self.bytes, { (ptr) -> String? in
//            
//            let uint8Ptr = unsafeBitCast(ptr, UnsafePointer<UInt8>.self)
//            
//            var byteString: String = String(format: "%02X", arguments: [uint8Ptr[0]])
//            for index in 1...5 {
//                byteString += String(format: "%02X", arguments: [uint8Ptr[index]])
//                //                uidString += String(format: ":%02X", arguments: [uint8Ptr[index]])
//            }
//            return byteString
//        })
//        
//        print(byteString!)
//        
//        return byteString ?? "no bytes"
//    }
//}

