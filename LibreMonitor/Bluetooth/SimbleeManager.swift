//
//  SimbleeManager.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 23.04.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//
//  How does the Simblee work?
//
//    1.) Services
///       The Simblee has only one service. By convention the service UUID is set to "2220" (this 
//        could be changed in the arduino code any time):
//
//        Service:
//        "<CBService: 0x14c72a810, isPrimary = YES, UUID = 2220>"
//
//    2.) Characteristics
//        Simble provides three Characteristics: one read and two write characteristics. This is
//        a "hard coded" feature of the simblee and cannot be changed. The debugDescription 
//        of these three characteristics is as follows:
//
//        a) Read Characteristic:
//               "<CBCharacteristic: 0x14c7664e0, UUID = 2221, properties = 0x12, value = (null), notifying = NO>"
//           ... with properties:
//              __C.CBCharacteristicProperties(rawValue: 18)
//              Broadcast:                            [false]
//              Read:                                 [true]
//              WriteWithoutResponse:                 [false]
//              Write:                                [false]
//              Notify:                               [true]
//              Indicate:                             [false]
//              AuthenticatedSignedWrites:            [false]
//              ExtendedProperties:                   [false]
//              NotifyEncryptionRequired:             [false]
//              BroaIndicateEncryptionRequireddcast:  [false]
//
//        b) First Write Characteristic:
//              "<CBCharacteristic: 0x14c766620, UUID = 2222, properties = 0xC, value = (null), notifying = NO>"
//           ... with properties:
//              __C.CBCharacteristicProperties(rawValue: 12)
//              Broadcast:                            [false]
//              Read:                                 [false]
//              WriteWithoutResponse:                 [true]
//              Write:                                [true]
//              Notify:                               [false]
//              Indicate:                             [false]
//              AuthenticatedSignedWrites:            [false]
//              ExtendedProperties:                   [false]
//              NotifyEncryptionRequired:             [false]
//              BroaIndicateEncryptionRequireddcast:  [false]
//
//        c) Second Write Characteristic:
//              "<CBCharacteristic: 0x14c766720, UUID = 2223, properties = 0xC, value = (null), notifying = NO>"
//           ... with properties:
//              __C.CBCharacteristicProperties(rawValue: 12)
//              Broadcast:                            [false]
//              Read:                                 [false]
//              WriteWithoutResponse:                 [true]
//              Write:                                [true]
//              Notify:                               [false]
//              Indicate:                             [false]
//              AuthenticatedSignedWrites:            [false]
//              ExtendedProperties:                   [false]
//              NotifyEncryptionRequired:             [false]
//              BroaIndicateEncryptionRequireddcast:  [false]
//
//   3.) Further information on Simblee services and characteristics can be found on
//       http://forum.rfduino.com/index.php?topic=1066.15
//

import Foundation
import UIKit
import CoreBluetooth


public enum SimbleeManagerState: String {
    case Unassigned = "Unassigned"
    case Scanning = "Scanning"
    case Disconnected = "Disconnected"
    case DisconnectedManually = "Disconnected manually"
    case Connecting = "Connecting"
    case Connected = "Connected"
    case Notifying = "Notifying"
}

protocol SimbleeManagerDelegate {
    func simbleeManagerPeripheralStateChanged(_ state:SimbleeManagerState)
    func simbleeManagerReceivedMessage(_ messageIdentifier:UInt16, txFlags:UInt8, payloadData:Data)
}

class SimbleeManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, SLIPBufferDelegate {
    
    // MARK: - Properties
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var slipBuffer = SLIPBuffer()
    
    fileprivate let serviceUUIDs:[CBUUID]? = [CBUUID(string: "2220")]
    
    var BLEScanDuration = 3.0
    
    var delegate: SimbleeManagerDelegate? {
        didSet {
            // Help delegate initialize by sending current state directly after delegate assignment
            delegate?.simbleeManagerPeripheralStateChanged(state)
        }
    }
    
    var state: SimbleeManagerState = .Unassigned {
        didSet {
            // Help delegate initialize by sending current state directly after delegate assignment
            delegate?.simbleeManagerPeripheralStateChanged(state)
        }
    }
    
    // MARK: - Methods
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        slipBuffer.delegate = self
    }
    
    func scanForSimblee() {
        if centralManager.state == .poweredOn {
            print ("Start scanning for Simblee")
            centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
            state = .Scanning
        }
    }
    
    func connect() {
        if let peripheral = peripheral {
            peripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
            state = .Connecting        }
    }
    
    func disconnectManually() {
        switch state {
        case .Connected, .Connecting, .Notifying:
            state = .DisconnectedManually  // to avoid reconnect in didDisconnetPeripheral
            centralManager.cancelPeripheralConnection(peripheral!)
        default:
            break
        }
//        if state == .Connected || peripheral?.state == .Connecting {
//            centralManager.cancelPeripheralConnection(peripheral!)
//        }
    }
    
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState")
        // TODO: maybe handle the case of bluetooth beeing switched of (and sometimes later) on again here by stopping and restarting scanning
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("didDiscoverPeripheral with name \(String(describing: peripheral.name))")
        
        self.peripheral = peripheral
        connect()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnectPeripheral")
        state = .Connected
        // Discover all Services. This might be helpful if writing is needed some time
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnectPeripheral")
        state = .Disconnected
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral")
        switch state {
        case .DisconnectedManually:
            state = .Disconnected
        default:
            state = .Disconnected
            scanForSimblee()
        }
        // Keep this code in case you want it some later time: it is used for reconnection only in background mode
//        state = .Disconnected
//        // Start scanning, if disconnection occurred in background mode
//        if UIApplication.sharedApplication().applicationState == .Background ||
//            UIApplication.sharedApplication().applicationState == .Inactive {
//            scanForSimblee()
//        }
    }
    
    
    // MARK: - CBPeripheralDelegate
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    
        print("didDiscoverServices")
        if let services = peripheral.services {
            print("Discovered services on RFduino");
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
//                print("Service: ")
//                debugPrint(service.debugDescription)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        print("didDiscoverCharacteristicsForService");
        if let error = error {
            print("An error occured: \(error.localizedDescription)")
        }

        if let characteristics = service.characteristics {
            for characteristic in characteristics {
//                print("Characteristic: ")
//                debugPrint(characteristic.debugDescription)
//                print("... with properties: ")
//                debugPrint(characteristic.properties)
//                print("Broadcast:                           ", [characteristic.properties.contains(.Broadcast)])
//                print("Read:                                ", [characteristic.properties.contains(.Read)])
//                print("WriteWithoutResponse:                ", [characteristic.properties.contains(.WriteWithoutResponse)])
//                print("Write:                               ", [characteristic.properties.contains(.Write)])
//                print("Notify:                              ", [characteristic.properties.contains(.Notify)])
//                print("Indicate:                            ", [characteristic.properties.contains(.Indicate)])
//                print("AuthenticatedSignedWrites:           ", [characteristic.properties.contains(.AuthenticatedSignedWrites )])
//                print("ExtendedProperties:                  ", [characteristic.properties.contains(.ExtendedProperties)])
//                print("NotifyEncryptionRequired:            ", [characteristic.properties.contains(.NotifyEncryptionRequired)])
//                print("BroaIndicateEncryptionRequireddcast: ", [characteristic.properties.contains(.IndicateEncryptionRequired)])
                
                // Choose the notifiying characteristic and Register to be notified whenever the simblee transmits
                if (characteristic.properties.intersection(.notify)) == .notify {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        } else {
            print("Discovered characteristics on RFduino, but no characteristics listed. There must be some error.");
        }
    }

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationStateForCharacteristic")
        if let error = error {
            print("An error occured: \(error.localizedDescription)")
        }
        state = .Notifying
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueForCharacteristic")
        if let error = error {
            print("Characteristic update error = \(error.localizedDescription)")
        } else {
            if let value = characteristic.value {
                slipBuffer.appendEscapedBytes(value)
            }
        }
    }
    
    
    // MARK: - SLIPBufferDelegate
    
    
    func slipBufferReceivedPayload(_ payloadData: Data, payloadIdentifier: UInt16, txFlags: UInt8) {
        
        // Inform delegate
        if let delegate = delegate {
            delegate.simbleeManagerReceivedMessage(payloadIdentifier, txFlags: txFlags, payloadData: payloadData)
        }
    }
    

}



















