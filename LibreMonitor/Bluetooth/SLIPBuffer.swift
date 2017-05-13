//
//  SLIPBuffer.swift
//  UBA-Demo
//
//  Created by Chas Conway on 2/4/15.
//  Copyright (c) 2015 Chas Conway. All rights reserved.
//
//  Modified by Uwe Petersen

import Foundation

let PacketIdentifierLength = MemoryLayout<UInt16>.size
let PacketFlagsLength = MemoryLayout<UInt8>.size
let PacketChecksumLength = MemoryLayout<UInt8>.size

protocol SLIPBufferDelegate {
	
	func slipBufferReceivedPayload(_ payloadData: Data, payloadIdentifier: UInt16, txFlags: UInt8)
}


class SLIPBuffer {

    var rxBuffer = Data()
	var delegate:SLIPBufferDelegate?
	
	/// Appends more escaped bytes (i.e. data that were received via bluetooth) to the buffer and scans the buffer for complete frames according to the Serial Line Internet Protocol (SLIP). If a complete frame is detected, its payload data is extracted and a delegate method is called.
	///
    /// The bytes that are appended are escaped bytes according to the serial line internet protocol (SLIP). SLIP works as follows:
    /// - A transmission packet (the payload data) is appended by a special "END" byte, which distinguishes the datagram boundaries in the byte stream.
    /// - If the END byte occurs in the payload data to be sent, the two byte sequence [ESC, ESC_END] is sent instead.
    /// - If the ESC byte occurs in the payload data to be sent, the two byte sequence [ESC, ESC_ESC] is sent instead.
    /// - Variants of the protocol may also begin transmission packets (the payload data) with an END byte (which is the case in this realization of SLIP)
    ///
    /// The special bytes used by SLIP are:
    /// - 0xC0 ... END     -> Frame End (and Frame Beginning in this realization)
    /// - 0xDB ... ESC     -> Frame Escape
    /// - 0xDC ... ESC_END -> Transposed Frame END
    /// - 0xDD ... ESC_ESC -> Transposed Frame ESC
    ///
    /// Reference: https://en.m.wikipedia.org/wiki/Serial_Line_Internet_Protocol
    ///
	/// - parameter escapedData: data with escape bytes to be appended to the buffer
	func appendEscapedBytes(_ escapedData: Data) {
		rxBuffer.append(escapedData)
		scanRxBufferForFrames()
	}
	
	
    /// Scans the buffer for complete frames according to the Serial Line Internet Protocol (SLIP). If a complete frame is detected, the crc is checked and the payload extracted and a delegate method called. 
    ///
    /// Extracting the payload means the following steps: 
    /// - Extract the payload from the SLIP frame:
    ///   - Remove the END byte at the beginning and at the end of the frame.
    ///   - If the original payload data had contained the special bytes END (0xC0) or ESC (0xDB) they where replaced by the special byte sequences [END, ESC_END] ([0xC0, 0xDC]) and [ESC, ESC_ESC] ([0xDB, 0xDD]) because of the SLIP and this has to be reversed. 
    /// - Check CRC and remove the rcr bytes:
    ///   - The datagram is appended with one byte containting a CRC8, calculated over the original payload data. This CRC8 is compared with the corresponding CRC8 of the payload data.
    /// - If the CRCs are equal, a delegate method is called with the payload data (with the one appended CRC byte removed).
    ///
    /// The serial line internet protocol (SLIP) works as follows:
    /// - A transmission packet (the payload data) is appended by a special "END" byte, which distinguishes the datagram boundaries in the byte stream.
    /// - If the END byte occurs in the payload data to be sent, the two byte sequence [ESC, ESC_END] is sent instead.
    /// - If the ESC byte occurs in the payload data to be sent, the two byte sequence [ESC, ESC_ESC] is sent instead.
    /// - Variants of the protocol may also begin transmission packets (the payload data) with an END byte (which is the case in this realization of SLIP)
    ///
    /// The special bytes used by SLIP are:
    /// - 0xC0 ... END     -> Frame End (and Frame Beginning in this realization)
    /// - 0xDB ... ESC     -> Frame Escape
    /// - 0xDC ... ESC_END -> Transposed Frame END
    /// - 0xDD ... ESC_ESC -> Transposed Frame ESC
    ///
    /// Reference: https://en.m.wikipedia.org/wiki/Serial_Line_Internet_Protocol
    ///
    func scanRxBufferForFrames() {
        
        // get indices of all END bytes
        // TODO: idexesOfEndBytes is an Objective-C-extension of NSData. Reprogram this in Swift for data type "Data"
        guard let endByteIndices = NSData.init(data: rxBuffer).indexesOfEndBytes() else {
            return
        }

        // Loop over the END bytes and search for a complete frame, i.e. a sequence of bytes as follows: [END ... at-least-two-bytes ... END]
		var previousEndByteIndex = NSNotFound
        for endByteIndex in endByteIndices {
            
            print(String(endByteIndex.description) as Any)
            
            if (previousEndByteIndex != NSNotFound) {
                
                if endByteIndex - previousEndByteIndex > 2 {  // Contains at least one byte and checksum byte
                    
                    print("Identified a potential SLIP frame")
                    
                    print(self.rxBuffer.debugDescription)
                    
                    // Extact the frame (END byte at beginning and end are aleady removed)
                    let escapedPacket = self.rxBuffer.subdata(in: Range((previousEndByteIndex + 1)..<endByteIndex))
                    
                    // Decode the packet (undo SLIP)
                    self.decodeSLIPPacket(escapedPacket)
                    
                } else {
                    
                    print("Ignoring improbable SLIP frame")
                }
            }
            previousEndByteIndex = endByteIndex
        }
    
		// Remove byte in buffer up to, but not including, the previous END byte, i.e. cut of everything before the beginning of the frame.
		if previousEndByteIndex != NSNotFound {
            rxBuffer.removeSubrange(0..<previousEndByteIndex)
        }
    }
	
	/// Decode the escape packet.
	///
    /// Decoding means that the ESC and END bytes that have been added to the packet to transfer it according to the slip (serial line internet protocol) are now removed from the escapedPacket. After that the delegate is called with the resulting unescaped packet.
    ///
	/// - parameter escapedPacket: packet that still contains ESC and END bytes (as they were needed for the serial line internet protocol)
	func decodeSLIPPacket(_ escapedPacket:Data) {
		
		// Remove SLIP escaping
        guard let unescapedPacket = (escapedPacket as NSData).unescaped() else {
            return
        }
		
		// Extract embedded checksum from packet
        var embeddedChecksumByte:UInt8 = 0
        unescapedPacket.copyBytes(to: &embeddedChecksumByte, from: Range((unescapedPacket.count - PacketChecksumLength)..<unescapedPacket.count))
        
        
        // 2016-07-30, Uwe Petersen: get unescaped packet without checksum
        let unescapedPacketWithoutChecksum = unescapedPacket.subdata(in: Range(0..<(unescapedPacket.count-PacketChecksumLength)))
		
        // Calculate checksum on payload bytes (2016-06-30, Uwe Petersen: seems to be an error to calculate on unescaped packet. Changed to escaped packet)
        let checksummedData = escapedPacket.subdata(in: Range(0..<escapedPacket.count - PacketChecksumLength))
        let calculatedChecksum = (checksummedData as NSData).crc8Checksum()
        
        if UInt8(bitPattern: calculatedChecksum) == embeddedChecksumByte { // crc is calulated as Int8 and thus has to be converted to UInt8
			
			if let aDelegate = delegate {
				
				// Extract payload and payload ID. (2016-06-30, Uwe Petersen: seems to be an error to calculate on unescaped packet. Changed to escaped packet)
				var identifier: UInt16 = 0;
                let _ = unescapedPacketWithoutChecksum.copyBytes(to: UnsafeMutableBufferPointer(start: &identifier, count: 1), from: Range(0..<PacketIdentifierLength))
				
                
                // 2016-06-30, Uwe Petersen: seems to be an error to calculate on unescaped packet. Changed to escaped packet
                var txFlags: UInt8 = 0;
                unescapedPacketWithoutChecksum.copyBytes(to: &txFlags, from: Range((PacketIdentifierLength-1)..<(PacketIdentifierLength-1+PacketFlagsLength)))
                
                let payloadData = unescapedPacketWithoutChecksum.subdata(in: Range( (PacketIdentifierLength + PacketFlagsLength)..<unescapedPacketWithoutChecksum.count ))
				
				// Notify delegate with payloadData 
				aDelegate.slipBufferReceivedPayload(payloadData, payloadIdentifier: identifier, txFlags: txFlags)
			}
			
		} else {

            print("SLIP frame failed checksum")
        }
	}
}
