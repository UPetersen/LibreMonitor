//
//  LibreSensor.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 15.05.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation

final class LibreSensor {
    
    var uid: String
    
    fileprivate let lookupTable = ["0","1","2","3","4","5","6","7","8","9","A","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","T","U","V","W","X","Y","Z"]
    
    lazy var serialNumber: String = {
        
        // The serial number of the sensor can be derived from its uid.
        //
        // The numbers an letters of the serial number are coded a compressed scheme that uses only 32 numbers and letters,
        // by omitting the letters B, I, O and S. This information is stored in consecutive units of five bits.
        //
        // The encoding thus is as follows:
        //   index: 0 1 2 3 4 5 6 7 8 9 10     11 12 13 14 15 16     17 18 19 20 21     22 23 24      25 26 27 28 29 30 31
        //   char:  0 1 2 3 4 5 6 7 8 9  A (B)  C  D  E  F  G  H (I)  J  K  L  M  N (O)  P  Q  R (S)   T  U  V  W  X  Y  Z
        //
//        8bd9043e67be0000a007e0 f307 fda7a80e030000
//        8bd90475ce860000a007e0 f307 50548055050003
        // Example:  75 ce 86 00 00 a0 07 e0
        //    Uid is E0 07 A0 00 00 25 90 5E, and the corresponding serial number is "0M00009DHCR"
        //           \   / \              /
        //            -+-   -----+--------
        //             |         |
        //             |         +-- This part encodes the serial number, see below
        //             +-- Standard first two bytes, where 0x07 is the code for "Texas Instruments Tag-it™", see https://en.wikipedia.org/wiki/ISO/IEC_15693
        //
        //   1.) Convert the part without E007, i.e. A0 00 00 25 90 5E to binary representation
        //
        //            A    0     0    0     0    0     2    5     9    0     5    E
        //          1010 0000  0000 0000  0000 0000  0010 0101  1001 0000  0101 1110
        //
        //   2.) Split this binary array in units of five bits length from the beginning and pad with two zeros at the end and
        //       calculate the corresponding integer and retreive the corresponding char from the table above
        //
        //     +--  1010 0000  0000 0000  0000 0000  0010 0101  1001 0000  0101 1110   + 00
        //     |
        //     +->  10100 00000 00000 00000 00000 01001 01100 10000 01011 11000
        //            |     |     |     |     |     |     |     |     |     |
        //            |     |     |     |     |     |     |     |     |     +- = 24 -> "R"
        //            |     |     |     |     |     |     |     |     +------- = 11 -> "C"
        //            |     |     |     |     |     |     |     +------------- = 16 -> "H"
        //            |     |     |     |     |     |     +------------------- = 12 -> "D"
        //            |     |     |     |     |     +------------------------- =  9 -> "9"
        //            |     |     |     |     +------------------------------- =  0 -> "0"
        //            |     |     |     +------------------------------------- =  0 -> "0"
        //            |     |     +------------------------------------------- =  0 -> "0"
        //            |     +------------------------------------------------- =  0 -> "0"
        //            +------------------------------------------------------- = 20 -> "M"
        //
        //   3.) Prepend "0" at the beginning an thus receive "0M00009DHCR"
        
        
//        let uidString = self.uid.substring(from: self.uid.index(self.uid.startIndex, offsetBy: 4)) // "E007A0000025905E" -> "A0000025905E"
        let uidString = self.uid.suffix(12) // "E007A0000025905E" -> "A0000025905E"

        var serialNumber = ""
        
        guard uidString.lengthOfBytes(using: String.Encoding.ascii) == 12,
            let uidAsInt = Int(uidString, radix: 16) // "A0000025905E"  -> 175921862905950
            else {return ""}
        
        let uidAsBinaryString = String(uidAsInt, radix: 2) + "00"  // -> "10100000000000000000000000100101100100000101111000"
        let length = uidAsBinaryString.lengthOfBytes(using: String.Encoding.ascii)
        
        for index in stride(from: 0, to: length, by: 5) {
            if index + 4 < length {
                let startIndex = uidAsBinaryString.startIndex
                let leftIndex = uidAsBinaryString.index(startIndex, offsetBy: index)
                let rightIndex = uidAsBinaryString.index(startIndex, offsetBy: index+5)
                let range = leftIndex..<rightIndex
//                let fiveBits = uidAsBinaryString.substring(with: range)
                let fiveBits = uidAsBinaryString[leftIndex..<rightIndex]

                if let theInt = Int(fiveBits, radix: 2) , theInt >= 0 && theInt < self.lookupTable.count {
                    serialNumber += self.lookupTable[theInt] // "10100" -> 20 -> "M"
                }
            }
        }
        serialNumber = "0" + serialNumber  // "M00009DHCR" -> "0M00009DHCR"
        return serialNumber
    }()
    
    lazy var prettyUid: String = {
        
        var prettyUid = self.uid
        let length = self.uid.lengthOfBytes(using: String.Encoding.ascii)
        for index in stride(from: 2, to: length, by: 2).reversed() {
            prettyUid.insert(Character(":"), at: prettyUid.index(prettyUid.startIndex, offsetBy: index))
        }
        return prettyUid
    }()
    
    
    init(withUID uid: String) {
        self.uid = uid
    }
    
}
