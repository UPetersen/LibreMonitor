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
import os.log



public enum SimbleeManagerState: String {
    case Unassigned = "Unassigned"
    case Scanning = "Scanning"
    case Disconnected = "Disconnected"
    case DisconnectingDueToButtonPress = "Disconnecting due to button press"
    case Connecting = "Connecting"
    case Connected = "Connected"
    case Notifying = "Notifying"
}

protocol SimbleeManagerDelegate {
    func simbleeManagerPeripheralStateChanged(_ state:SimbleeManagerState)
    func simbleeManagerReceivedMessage(_ messageIdentifier:UInt16, txFlags:UInt8, payloadData:Data)
}

final class SimbleeManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, SLIPBufferDelegate {
    
    // MARK: - Properties

    static let bt_log = OSLog(subsystem: "com.LibreMonitor", category: "SimbleeManager")

    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var slipBuffer = SLIPBuffer()
    
    fileprivate let serviceUUIDs:[CBUUID]? = [CBUUID(string: "2220")]
    
    var BLEScanDuration = 3.0
    weak var timer: Timer?
    
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
        os_log("Scan for simblee while state %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: state.rawValue))
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
            state = .Scanning
        }

        // Set timer to check connection and reconnect if necessary
        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false) {_ in
            os_log("********** Reconnection timer fired in background **********", log: SimbleeManager.bt_log, type: .default)
            if self.state != .Notifying {
                self.scanForSimblee()
//                NotificationManager.scheduleDebugNotification(message: "Reconnection timer fired in background", wait: 0.5)
            }
        }
    }
    
    func connect() {
        os_log("Connect while state %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: state.rawValue))
        if let peripheral = peripheral {
            peripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
            state = .Connecting        }
    }
    
    func disconnectManually() {
        os_log("Disconnect manually while state %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: state.rawValue))
//        NotificationManager.scheduleDebugNotification(message: "Timer fired in Background", wait: 3)
//        _ = Timer(timeInterval: 150, repeats: false, block: {timer in NotificationManager.scheduleDebugNotification(message: "Timer fired in Background", wait: 0.5)})

        switch state {
        case .Connected, .Connecting, .Notifying:
            state = .DisconnectingDueToButtonPress  // to avoid reconnect in didDisconnetPeripheral
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

        os_log("Central Manager did update state to %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: central.state.rawValue))
        
        switch central.state {
        case .poweredOff, .resetting, .unauthorized, .unknown, .unsupported:
            state = .Unassigned
        case .poweredOn:
            scanForSimblee() // power was switched on, while app is running -> reconnect.
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        os_log("Did discover peripheral while state %{public}@ with name: %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: state.rawValue), String(describing: peripheral.name))
        
        
        
        self.peripheral = peripheral
        connect()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        os_log("Did connect peripheral while state %{public}@ with name: %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: state.rawValue), String(describing: peripheral.name))
        state = .Connected
        // Discover all Services. This might be helpful if writing is needed some time
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {

        os_log("Did fail to connect peripheral while state: %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: state.rawValue))
        if let error = error {
            os_log("Did fail to connect peripheral error: %{public}@", log: SimbleeManager.bt_log, type: .error ,  "\(error.localizedDescription)")
        }
        state = .Disconnected
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {


        os_log("Did disconnect peripheral while state: %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: state.rawValue))
        if let error = error {
            os_log("Did disconnect peripheral error: %{public}@", log: SimbleeManager.bt_log, type: .error ,  "\(error.localizedDescription)")
        }

        
        switch state {
        case .DisconnectingDueToButtonPress:
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
    
        os_log("Did discover services", log: SimbleeManager.bt_log, type: .default)
        if let error = error {
            os_log("Did discover services error: %{public}@", log: SimbleeManager.bt_log, type: .error ,  "\(error.localizedDescription)")
        }


        if let services = peripheral.services {

            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)

                os_log("Did discover service: %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: service.debugDescription))
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        os_log("Did discover characteristics for service %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: peripheral.name))

        if let error = error {
            os_log("Did discover characteristics for service error: %{public}@", log: SimbleeManager.bt_log, type: .error ,  "\(error.localizedDescription)")
        }

        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                os_log("Did discover characteristic: %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: characteristic.debugDescription))
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
                    os_log("Set notify value for this characteristic", log: SimbleeManager.bt_log, type: .default)
                }
            }
        } else {
            os_log("Discovered characteristics, but no characteristics listed. There must be some error.", log: SimbleeManager.bt_log, type: .default)
        }
    }

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {

        os_log("Did update notification state for characteristic: %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: characteristic.debugDescription))

        if let error = error {
            os_log("Peripheral did update notification state for characteristic: %{public}@", log: SimbleeManager.bt_log, type: .error ,  "\(error.localizedDescription)")
        }
        state = .Notifying
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        os_log("Did update value for characteristic: %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: characteristic.debugDescription))

        if let error = error {
            os_log("Characteristic update error: %{public}@", log: SimbleeManager.bt_log, type: .error ,  "\(error.localizedDescription)")
            
        } else {
            if let value = characteristic.value {
                os_log("Updated value: %{public}@", log: SimbleeManager.bt_log, type: .default, String(describing: characteristic.value?.debugDescription))
                slipBuffer.appendEscapedBytes(value)
                os_log("... after append escaped bytes", log: SimbleeManager.bt_log, type: .default)
            }
        }
    }
    
    
    // MARK: - SLIPBufferDelegate
    
    
    func slipBufferReceivedPayload(_ payloadData: Data, payloadIdentifier: UInt16, txFlags: UInt8) {
        os_log("Slip buffer received payload with identifier %{public}@", log: SimbleeManager.bt_log, type: .default, String(payloadIdentifier))

        
        // Inform delegate
        if let delegate = delegate {
            os_log("Inform slip buffer delegate", log: SimbleeManager.bt_log, type: .default)
            delegate.simbleeManagerReceivedMessage(payloadIdentifier, txFlags: txFlags, payloadData: payloadData)
        }
    }
    
}



















