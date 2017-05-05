//
//  Data_types+Extensions.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 15.05.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation

extension IDNDataType {
    
    var idArray: [UInt8] {
        var tmp = self.deviceID
        // reference: https://forums.developer.apple.com/thread/72120
        return [UInt8](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
    }
    
    var idString: String {
        let stringArray = self.idArray.map({String(format: "%02X", $0)})
        return stringArray.dropFirst().reduce(stringArray.first!,  {$0 + ":" + $1} )
    }

    public var description: String {
        
        var theString = String()
        theString.append(String("IDNDataType:\n"))
        theString.append(String(format: "  ResultCode: %02X\n", arguments: [self.resultCode]))
        theString.append("  Device id: \(idString)\n")
        return theString
    }
}


extension SystemInformationDataType: CustomStringConvertible {
    
    var uidArray: [UInt8] {
        var tmp = self.uid
        // reference: https://forums.developer.apple.com/thread/72120
        return [UInt8](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
    }
    
    var uidString: String {
        let stringArray = self.uidArray.map({String(format: "%02X", $0)})
        return stringArray.dropFirst().reduce(stringArray.first!,  {$0 + ":" + $1} )
    }

    public var description: String {

        var theString = String()
        theString.append("SystemInformationDataType:\n")
        theString.append(String(format: "  Result code %02X\n", arguments: [self.resultCode]))
        theString.append(String(format: "  Response flags %02X\n", arguments: [self.responseFlags]))
        theString.append(String(format: "  Info flags %02X\n", arguments: [self.infoFlags]))
        theString.append(String(format: "  Error code %02X\n", arguments: [self.errorCode]))
        theString.append("  Uid String: \(uidString)\n")
        return theString
    }
}

// Extensions for initialization with bytes as received via bluetooth
extension BatteryDataType:           initializableWithBytes { }
extension SystemInformationDataType: initializableWithBytes { }
extension IDNDataType:               initializableWithBytes { }
extension AllBytesDataType:          initializableWithBytes { }


/// Protocol with default implementation for initializer with bytes as received via bluetoth.
protocol initializableWithBytes {
    init()
    init(bytes: Data)
}

/// Extension with default initializer for bytes
extension initializableWithBytes {
    /// Init with bytes as received via bluetooth.
    ///
    /// - Parameter bytes: the bytes
    init(bytes: Data) {
        self.init()
        self = bytes.withUnsafeBytes { $0.pointee }
    }
}


