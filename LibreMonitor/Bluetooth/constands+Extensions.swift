//
//  constands+Extensions.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 07.05.17.
//  Copyright © 2017 Uwe Petersen. All rights reserved.
//

import Foundation


/// Enum to handle data received via bluetooth.
///
/// All data transmitted via bluetooth is transmitted as structs. These structs are defined in data_types.h and are distinguished by identifiers defined in constants.h. This enum is used to access the cases directly instead of using raw integer values.
/// - IDN_DATA: IDNDataType
/// - SYSTEM_INFORMATION_DATA: SystemInformationDataType
/// - BATTERY_DATA: BatteryDataType
/// - NFC_STATE: NFCState
/// - ALL_BYTES: AllBytesDataType
enum ReceivedDataType: UInt16 {
    case IDN_DATA = 1
    case SYSTEM_INFORMATION_DATA = 2
    case BATTERY_DATA = 3
    case NFC_STATE = 4
    case ALL_BYTES = 5
}

