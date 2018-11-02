//
//  MiaoMiaoManager.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 10.03.18.
//  Copyright © 2018 Uwe Petersen. All rights reserved.
//
//  How does the MiaoMiao work?
//
//    0.) Advertising
//        MiaoMiao advertises with the following data:
//        - key : "kCBAdvDataIsConnectable"     - value : 1
//        - key : "kCBAdvDataManufacturerData"  - value : <0034cb1c 53093fb4> -> This might be usable as a unique device id.
//        - key : "kCBAdvDataLocalName"         - value : miaomiao
//
//    1.) Services
///       The MiaoMiao has two bluetooth services, one provided for the open source community and one that is probably to be used by the Tomato app.
//        a) UUID: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E -> Open Source Community
//           Did discover service: <CBService: 0x1c4673a00, isPrimary = YES, UUID = 6E400001-B5A3-F393-E0A9-E50E24DCCA9E>
//        b) UUID: 00001532-1212-EFDE-1523-785FEABCD123
//           Did discover service: <CBService: 0x1c0a61880, isPrimary = YES, UUID = 00001530-1212-EFDE-1523-785FEABCD123>
//
//    2.) Characteristics for open source service with UUID 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
//
//        The service contains two characheristics:
//
//          a) Notify_Characteristic
//             UUID: 6E400003-B5A3-F393-E0A9-E50E24DCCA9E
//             "<CBCharacteristic: 0x1c02ae7c0, UUID = 6E400003-B5A3-F393-E0A9-E50E24DCCA9E, properties = 0x10, value = (null), notifying = NO>"
//                 ... with properties:
//             __C.CBCharacteristicProperties(rawValue: 16)
//             Broadcast:                            [false]
//             Read:                                 [false]
//             WriteWithoutResponse:                 [false]
//             Write:                                [false]
//             Notify:                               [true]
//             Indicate:                             [false]
//             AuthenticatedSignedWrites:            [false]
//             ExtendedProperties:                   [false]
//             NotifyEncryptionRequired:             [false]
//             BroaIndicateEncryptionRequireddcast:  [false]
//             Service for Characteristic:           ["<CBService: 0x1c087f940, isPrimary = YES, UUID = 6E400001-B5A3-F393-E0A9-E50E24DCCA9E>"]
//
//          b) Write_Characteristic
//             UUID: 6E400002-B5A3-F393-E0A9-E50E24DCCA9E
//             "<CBCharacteristic: 0x1c02a81c0, UUID = 6E400002-B5A3-F393-E0A9-E50E24DCCA9E, properties = 0xC, value = (null), notifying = NO>"
//                 ... with properties:
//             __C.CBCharacteristicProperties(rawValue: 12)
//             Broadcast:                            [false]
//             Read:                                 [false]
//             WriteWithoutResponse:                 [true]
//             Write:                                [true]
//             Notify:                               [false]
//             Indicate:                             [false]
//             AuthenticatedSignedWrites:            [false]
//             ExtendedProperties:                   [false]
//             NotifyEncryptionRequired:             [false]
//             BroaIndicateEncryptionRequireddcast:  [false]
//             Service for Characteristic:           ["<CBService: 0x1c087f940, isPrimary = YES, UUID = 6E400001-B5A3-F393-E0A9-E50E24DCCA9E>"]
//
//      3.) Characteristics for (possibly) Tomato app services with UUID 00001532-1212-EFDE-1523-785FEABCD123
//
//          The service contains three characteristics
//
//          a) Read characteristic
//             "<CBCharacteristic: 0x1c42a8c40, UUID = 00001534-1212-EFDE-1523-785FEABCD123, properties = 0x2, value = (null), notifying = NO>"
//                 ... with properties:
//             __C.CBCharacteristicProperties(rawValue: 2)
//             Broadcast:                            [false]
//             Read:                                 [true]
//             WriteWithoutResponse:                 [false]
//             Write:                                [false]
//             Notify:                               [false]
//             Indicate:                             [false]
//             AuthenticatedSignedWrites:            [false]
//             ExtendedProperties:                   [false]
//             NotifyEncryptionRequired:             [false]
//             BroaIndicateEncryptionRequireddcast:  [false]
//             Service for Characteristic:           ["<CBService: 0x1c0a61880, isPrimary = YES, UUID = 00001530-1212-EFDE-1523-785FEABCD123>"]
//
//          b) Write without respons characteristic
//             Characteristic:
//             "<CBCharacteristic: 0x1c42a2220, UUID = 00001532-1212-EFDE-1523-785FEABCD123, properties = 0x4, value = (null), notifying = NO>"
//             ... with properties:
//             __C.CBCharacteristicProperties(rawValue: 4)
//             Broadcast:                            [false]
//             Read:                                 [false]
//             WriteWithoutResponse:                 [true]
//             Write:                                [false]
//             Notify:                               [false]
//             Indicate:                             [false]
//             AuthenticatedSignedWrites:            [false]
//             ExtendedProperties:                   [false]
//             NotifyEncryptionRequired:             [false]
//             BroaIndicateEncryptionRequireddcast:  [false]
//             Service for Characteristic:           ["<CBService: 0x1c0a61880, isPrimary = YES, UUID = 00001530-1212-EFDE-1523-785FEABCD123>"]
//
//          c) Write and notify characteristic
//             "<CBCharacteristic: 0x1c02a8220, UUID = 00001531-1212-EFDE-1523-785FEABCD123, properties = 0x18, value = (null), notifying = NO>"
//                 ... with properties:
//             __C.CBCharacteristicProperties(rawValue: 24)
//             Broadcast:                            [false]
//             Read:                                 [false]
//             WriteWithoutResponse:                 [false]
//             Write:                                [true]
//             Notify:                               [true]
//             Indicate:                             [false]
//             AuthenticatedSignedWrites:            [false]
//             ExtendedProperties:                   [false]
//             NotifyEncryptionRequired:             [false]
//             BroaIndicateEncryptionRequireddcast:  [false]
//             Service for Characteristic:           ["<CBService: 0x1c0a61880, isPrimary = YES, UUID = 00001530-1212-EFDE-1523-785FEABCD123>"]
//
//  The MiaoMiao protocol
//  1.) Data
//      TX: 0xF0
//          Request all the data or the sensor. The bluetooth will return the data at a certain frequency (default is every 5 minutes) after the request
//      RX:
//          a) Data (363 bytes):
//             Pos.  0 (0x00): 0x28 +
//             Pos.  1 (0x01): Len[2 bytes] +
//             Pos.  3 (0x03): Index [2 bytes] (this is the minute counter of the Freestyle Libre sensor) +
//             Pos.  5 (0x05): ID [8 bytes] +
//             Pos. 13 (0x0D): xbattery level in percent [1 byte] (e.g. 0x64 which is 100 in decimal means 100%?)
//             Pos. 14 (0x0E): firmware version [2 bytes] +
//             Pos. 16 (0x10): hardware version [2 bytes] +
//             Pos. 18 (0x12): FRAM data (43 x 8 bytes = 344 bytes) +
//             Pos. end      : 0x29
//             Example: 28  07b3  5457  db353e01 00a007e0  64  0034 0001  11b6e84f050003 875104 57540000 00 000000 00000000 0000b94b 060f1600 c0da6a80 1600c0d6 6a801600
//                      0x28   -> marks begin of data response
//                      0x07b3 -> len is 1971 bytes (= 1952 for FRAM and 19 bytes for all the rest from 0x28 to 0x29, both of which are included)
//                                but as of 2018-03-12 only 1791 bytes are sent.
//                      0x5457 -> index is 21591
//                      0xdb353e0100a007e0 -> id, can be converted to serial number
//                      0x64   -> battery level (= 100%)
//                      0x0034 -> firmware version
//                      0x0001 -> hardware version
//                      0x11b6e84f05000387 FRAM block 0x00 (sensor is expired since byte 0x04 has value 0x05)
//                      0x5104575400000000 FRAM block 0x01
//                      0x0000000000000000 FRAM block 0x02
//                      0xb94b060f1600c0da FRAM block 0x03
//                       ...
//            28 07b3 182b  9a8150 0100a007 e0640034 0001539d
//          b) A new sensor has been detected
//             0x32
//          c) No sensor has been detected
//             0x34
//
//  2.) Confirm to replace the sensor (if a new sensor is detected and shall be used, send this)
//      TX: 0xD301
//  3.) Confirm not to replace the sensor (if a new sensor is detected and shall not be used, send this)
//      TX: 0xD300
//  4.) Change the frequence of data transmission
//      TX: 0xD1XX, where XX is the intervall time, 1 byte, e.g. 0x0A is 10 minutes
//      RX:
//          a) 0xD101 Success
//          b) 0xD100 Fail

import Foundation
import UIKit
import CoreBluetooth
import os.log

public enum MiaoMiaoManagerState: String {
    case Unassigned = "Unassigned"
    case Scanning = "Scanning"
    case Disconnected = "Disconnected"
    case DisconnectingDueToButtonPress = "Disconnecting due to button press"
    case Connecting = "Connecting"
    case Connected = "Connected"
    case Notifying = "Notifying"
}

public enum MiaoMiaoResponseState: UInt8 {
    case dataPacketReceived = 0x28
    case newSensor = 0x32
    case noSensor = 0x34
    case frequencyChangedResponse = 0xD1
}
extension MiaoMiaoResponseState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dataPacketReceived:
            return "Data packet received"
        case .newSensor:
            return "New sensor detected"
        case .noSensor:
            return "No sensor found"
        case .frequencyChangedResponse:
            return "Reading intervall changed"
        }
    }
}

protocol MiaoMiaoManagerDelegate {
    func miaoMiaoManagerPeripheralStateChanged(_ state: MiaoMiaoManagerState)
    func miaoMiaoManagerReceivedMessage(_ messageIdentifier:UInt16, txFlags:UInt8, payloadData:Data)
    func miaoMiaoManagerDidUpdateSensorAndMiaoMiao(sensorData: SensorData, miaoMiao: MiaoMiao) -> Void
}

final class MiaoMiaoManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: - Properties
    
    static let bt_log = OSLog(subsystem: "com.LibreMonitor", category: "MiaoMiaoManager")
    var miaoMiao: MiaoMiao?
    var miaoMiaoResponseState: MiaoMiaoResponseState?
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
//    var slipBuffer = SLIPBuffer()
    var writeCharacteristic: CBCharacteristic?
    
    var rxBuffer = Data()
    
//    fileprivate let serviceUUIDs:[CBUUID]? = [CBUUID(string: "6E400001B5A3F393E0A9E50E24DCCA9E")]
    fileprivate let deviceName = "miaomiao"
    fileprivate let serviceUUIDs:[CBUUID]? = [CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")]

    var BLEScanDuration = 3.0
    weak var timer: Timer?
    
    var delegate: MiaoMiaoManagerDelegate? {
        didSet {
            // Help delegate initialize by sending current state directly after delegate assignment
            delegate?.miaoMiaoManagerPeripheralStateChanged(state)
        }
    }
    
    var state: MiaoMiaoManagerState = .Unassigned {
        didSet {
            // Help delegate initialize by sending current state directly after delegate assignment
            delegate?.miaoMiaoManagerPeripheralStateChanged(state)
        }
    }
    
    // MARK: - Methods
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
//        slipBuffer.delegate = self
    }
    
    func scanForMiaoMiao() {
        os_log("Scan for MiaoMiao while state %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: state.rawValue))
//        print(centralManager.debugDescription)
        if centralManager.state == .poweredOn {
            os_log("Before scan for MiaoMiao while central manager state %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: centralManager.state.rawValue))
            
            centralManager.scanForPeripherals(withServices: nil, options: nil)

            state = .Scanning
            os_log("Before scan for MiaoMiao while central manager state %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: centralManager.state.rawValue))
//            print(centralManager.debugDescription)
        }
//        // Set timer to check connection and reconnect if necessary
//        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false) {_ in
//            os_log("********** Reconnection timer fired in background **********", log: MiaoMiaoManager.bt_log, type: .default)
//            if self.state != .Notifying {
//                self.scanForMiaoMiao()
//                //                NotificationManager.scheduleDebugNotification(message: "Reconnection timer fired in background", wait: 0.5)
//            }
//        }
    }
    
    func connect() {
        os_log("Connect while state %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: state.rawValue))
        if let peripheral = peripheral {
            peripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
            state = .Connecting
        }
    }
    
    func disconnectManually() {
        os_log("Disconnect manually while state %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: state.rawValue))
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
        
        os_log("Central Manager did update state to %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: central.state.rawValue))
        
        switch central.state {
        case .poweredOff, .resetting, .unauthorized, .unknown, .unsupported:
            state = .Unassigned
        case .poweredOn:
            scanForMiaoMiao() // power was switched on, while app is running -> reconnect.
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        os_log("Did discover peripheral while state %{public}@ with name: %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: state.rawValue), String(describing: peripheral.name))
        
        
        
        if peripheral.name == deviceName {
            
            self.peripheral = peripheral
            connect()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        os_log("Did connect peripheral while state %{public}@ with name: %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: state.rawValue), String(describing: peripheral.name))
        state = .Connected
        // Discover all Services. This might be helpful if writing is needed some time
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        os_log("Did fail to connect peripheral while state: %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: state.rawValue))
        if let error = error {
            os_log("Did fail to connect peripheral error: %{public}@", log: MiaoMiaoManager.bt_log, type: .error ,  "\(error.localizedDescription)")
        }
        state = .Disconnected
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        
        os_log("Did disconnect peripheral while state: %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: state.rawValue))
        if let error = error {
            os_log("Did disconnect peripheral error: %{public}@", log: MiaoMiaoManager.bt_log, type: .error ,  "\(error.localizedDescription)")
        }
        
        
        switch state {
        case .DisconnectingDueToButtonPress:
            state = .Disconnected
        default:
            state = .Disconnected
            connect()
//            scanForMiaoMiao()
        }
        // Keep this code in case you want it some later time: it is used for reconnection only in background mode
        //        state = .Disconnected
        //        // Start scanning, if disconnection occurred in background mode
        //        if UIApplication.sharedApplication().applicationState == .Background ||
        //            UIApplication.sharedApplication().applicationState == .Inactive {
        //            scanForMiaoMiao()
        //        }
    }
    
    
    // MARK: - CBPeripheralDelegate
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        os_log("Did discover services", log: MiaoMiaoManager.bt_log, type: .default)
        if let error = error {
            os_log("Did discover services error: %{public}@", log: MiaoMiaoManager.bt_log, type: .error ,  "\(error.localizedDescription)")
        }
        
        
        if let services = peripheral.services {
            
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
                
                os_log("Did discover service: %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: service.debugDescription))
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        os_log("Did discover characteristics for service %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: peripheral.name))
        
        if let error = error {
            os_log("Did discover characteristics for service error: %{public}@", log: MiaoMiaoManager.bt_log, type: .error ,  "\(error.localizedDescription)")
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                os_log("Did discover characteristic: %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: characteristic.debugDescription))
//                print("Characteristic: ")
//                debugPrint(characteristic.debugDescription)
//                print("... with properties: ")
//                debugPrint(characteristic.properties)
//                print("Broadcast:                           ", [characteristic.properties.contains(.broadcast)])
//                print("Read:                                ", [characteristic.properties.contains(.read)])
//                print("WriteWithoutResponse:                ", [characteristic.properties.contains(.writeWithoutResponse)])
//                print("Write:                               ", [characteristic.properties.contains(.write)])
//                print("Notify:                              ", [characteristic.properties.contains(.notify)])
//                print("Indicate:                            ", [characteristic.properties.contains(.indicate)])
//                print("AuthenticatedSignedWrites:           ", [characteristic.properties.contains(.authenticatedSignedWrites )])
//                print("ExtendedProperties:                  ", [characteristic.properties.contains(.extendedProperties)])
//                print("NotifyEncryptionRequired:            ", [characteristic.properties.contains(.notifyEncryptionRequired)])
//                print("BroaIndicateEncryptionRequireddcast: ", [characteristic.properties.contains(.indicateEncryptionRequired)])
//                print("Serivce for Characteristic:          ", [characteristic.service.debugDescription])
//
//                if characteristic.service.uuid == CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E") {
//                    print("\n B I N G O \n")
//                }

                // Choose the notifiying characteristic and Register to be notified whenever the MiaoMiao transmits
                if (characteristic.properties.intersection(.notify)) == .notify && characteristic.uuid == CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E") {
                    peripheral.setNotifyValue(true, for: characteristic)
                    os_log("Set notify value for this characteristic", log: MiaoMiaoManager.bt_log, type: .default)
                }
                if (characteristic.uuid == CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")) {
                    writeCharacteristic = characteristic
                }
            }
        } else {
            os_log("Discovered characteristics, but no characteristics listed. There must be some error.", log: MiaoMiaoManager.bt_log, type: .default)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        os_log("Did update notification state for characteristic: %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: characteristic.debugDescription))
        
        if let error = error {
            os_log("Peripheral did update notification state for characteristic: %{public}@ with error", log: MiaoMiaoManager.bt_log, type: .error ,  "\(error.localizedDescription)")
        } else {
            resetBuffer()
            requestData()
        }
        state = .Notifying
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        os_log("Did update value for characteristic: %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: characteristic.debugDescription))
        
        if let error = error {
            os_log("Characteristic update error: %{public}@", log: MiaoMiaoManager.bt_log, type: .error ,  "\(error.localizedDescription)")
        } else {
            if characteristic.uuid == CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"), let value = characteristic.value {

                rxBuffer.append(value)
                os_log("Appended value with length %{public}@, buffer length is: %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(describing: value.count), String(describing: rxBuffer.count))
                
                if let firstByte = rxBuffer.first {
                    miaoMiaoResponseState = MiaoMiaoResponseState(rawValue: firstByte)
                    if let miaoMiaoResponseState = miaoMiaoResponseState {
                        switch miaoMiaoResponseState {
                        case .dataPacketReceived: // 0x28: // data received, append to buffer and inform delegate if end reached
                            
                            // Set timer to check if data is still uncomplete after a certain time frame
                            // Any old buffer is invalidated and a new buffer created with every reception of data
                            timer?.invalidate()
                            timer = Timer.scheduledTimer(withTimeInterval: 8, repeats: false) { _ in
                                os_log("********** MiaoMiaoManagertimer fired **********", log: MiaoMiaoManager.bt_log, type: .default)
                                if self.rxBuffer.count >= 364 {
                                    // buffer large enough and can be used
                                    os_log("Buffer incomplete but large enough, inform delegate.", log: MiaoMiaoManager.bt_log, type: .default)
                                    self.delegate?.miaoMiaoManagerReceivedMessage(0x0000, txFlags: 0x29, payloadData: self.rxBuffer)
                                    self.handleCompleteMessage()

                                    self.rxBuffer = Data()  // reset buffer, once completed and delegate is informed
                                } else {
                                    // buffer not large enough and has to be reset
                                    os_log("Buffer incomplete and not large enough, reset buffer and request new data, again", log: MiaoMiaoManager.bt_log, type: .default)
                                    self.requestData()
                                }
                            }
                            
                            if rxBuffer.count >= 363 && rxBuffer.last! == 0x29 {
                                os_log("Buffer complete, inform delegate.", log: MiaoMiaoManager.bt_log, type: .default)
                                delegate?.miaoMiaoManagerReceivedMessage(0x0000, txFlags: 0x28, payloadData: rxBuffer)
                                handleCompleteMessage()
                                rxBuffer = Data()  // reset buffer, once completed and delegate is informed
                                timer?.invalidate()
                            } else {
                                // buffer not yet complete, inform delegate with txFlags 0x27 to display intermediate data
                                delegate?.miaoMiaoManagerReceivedMessage(0x0000, txFlags: 0x27, payloadData: rxBuffer)
                            }
                            
                            // if data is not complete after 10 seconds: use anyways, if long enough, do not use if not long enough and reset buffer in both cases.
                            
                        case .newSensor: // 0x32: // A new sensor has been detected -> acknowledge to use sensor and reset buffer
                            delegate?.miaoMiaoManagerReceivedMessage(0x0000, txFlags: 0x32, payloadData: rxBuffer)
                            if let writeCharacteristic = writeCharacteristic {
                                peripheral.writeValue(Data.init(bytes: [0xD3, 0x01]), for: writeCharacteristic, type: .withResponse)
                            }
                            rxBuffer = Data()
                        case .noSensor: // 0x34: // No sensor has been detected -> reset buffer (and wait for new data to arrive)
                            delegate?.miaoMiaoManagerReceivedMessage(0x0000, txFlags: 0x34, payloadData: rxBuffer)
                            rxBuffer = Data()
                        case .frequencyChangedResponse: // 0xD1: // Success of fail for setting time intervall
                            delegate?.miaoMiaoManagerReceivedMessage(0x0000, txFlags: 0xD1, payloadData: rxBuffer)
                            if rxBuffer.count >= 2 {
                                if rxBuffer[2] == 0x01 {
                                    os_log("Success setting time interval.", log: MiaoMiaoManager.bt_log, type: .default)
                                } else if rxBuffer[2] == 0x00 {
                                    os_log("Failure setting time interval.", log: MiaoMiaoManager.bt_log, type: .default)
                                } else {
                                    os_log("Unkown response for setting time interval.", log: MiaoMiaoManager.bt_log, type: .default)
                                }
                            }
                            rxBuffer = Data()
                            //                    default: // any other data (e.g. partial response ...)
                            //                        delegate?.miaoMiaoManagerReceivedMessage(0x0000, txFlags: 0x99, payloadData: rxBuffer)
                            //                        rxBuffer = Data() // reset buffer, since no valid response
                        }
                    }
                } else {
                    // any other data (e.g. partial response ...)
                    delegate?.miaoMiaoManagerReceivedMessage(0x0000, txFlags: 0x99, payloadData: rxBuffer)
                    rxBuffer = Data() // reset buffer, since no valid response
                }
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        os_log("Did Write value %{public}@ for characteristic %{public}@", log: MiaoMiaoManager.bt_log, type: .default, String(characteristic.value.debugDescription), String(characteristic.debugDescription))
    }
    
    // Miaomiao specific commands
    
    // Confirm (to replace) the sensor. Iif a new sensor is detected and shall be used, send this command (0xD301)
    func confirmSensor() {
        if let writeCharacteristic = writeCharacteristic {
            peripheral?.writeValue(Data.init(bytes: [0xD3, 0x00]), for: writeCharacteristic, type: .withResponse)
        }
    }
    
    func requestData() {
        if let writeCharacteristic = writeCharacteristic {
            confirmSensor()
            resetBuffer()
            timer?.invalidate()
            peripheral?.writeValue(Data.init(bytes: [0xF0]), for: writeCharacteristic, type: .withResponse)
        }
    }

    
    func resetBuffer() {
        rxBuffer = Data()
    }
    
    func handleCompleteMessage() {
        guard rxBuffer.count >= 363 else {
            return
        }

        miaoMiao = MiaoMiao(hardware: String(describing: rxBuffer[16...17].hexEncodedString()),
                            firmware: String(describing: rxBuffer[14...15].hexEncodedString()),
                            battery: Int(rxBuffer[13]))

         let sensorData = SensorData(uuid: Data(rxBuffer.subdata(in: 5..<13)), bytes: [UInt8](rxBuffer.subdata(in: 18..<362)), date: Date())

        guard let miaoMiao = miaoMiao else {
            return
        }
        
        // Set notifications
        NotificationManager.scheduleApplicationTerminatedNotification(wait: 500)
        NotificationManager.scheduleDataTransferInterruptedNotification(wait: 400)

        if miaoMiao.battery < 20 {
            NotificationManager.setLowBatteryNotification(voltage: Double(miaoMiao.battery))
        }

        // Check if sensor data is valid and reread, if this is not the case
        
        if let sensorData = sensorData {
            if !(sensorData.hasValidHeaderCRC && sensorData.hasValidBodyCRC && sensorData.hasValidFooterCRC) {
                Timer.scheduledTimer(withTimeInterval: 30, repeats: false, block: {_ in
                    self.requestData()
                })
            }
        }

        
        // Inform delegate
        delegate?.miaoMiaoManagerDidUpdateSensorAndMiaoMiao(sensorData: sensorData!, miaoMiao: miaoMiao)

        
        
    }
    
}
