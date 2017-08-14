//
//  NSUserDefaults.swift
//  RileyLink
//
//  Created by Pete Schwamb on 6/23/16.
//  Copyright © 2016 Pete Schwamb. All rights reserved.
//

import Foundation


extension UserDefaults {
    private enum Key: String {
        case LastStoredTreatmentTimestamp = "com.rileylink.NightscoutUploadKit.LastStoredTreatmentTimestamp"
    }
    
    var lastStoredTreatmentTimestamp: Date? {
        get {
            return object(forKey: Key.LastStoredTreatmentTimestamp.rawValue) as? Date
        }
        set {
            set(newValue, forKey: Key.LastStoredTreatmentTimestamp.rawValue)
        }
    }
}
