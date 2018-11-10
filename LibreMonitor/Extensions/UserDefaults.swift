//
//  UserDefaults.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 09.11.18.
//  Copyright © 2018 Uwe Petersen. All rights reserved.
//

import Foundation

extension UserDefaults {
    private enum Key: String {
        // Nightscout
        case uploadToNightscoutIsActivated = "uploadToNightscoutIsActivated"
        case nightscoutSite = "nightscoutSite"
        case nightscoutAPISecret = "nightscoutAPISecret"
        // OOP Web interface
        case oopWebInterfaceIsActivated = "oopWebInterfaceIsActivated"
        case oopWebInterfaceSite = "oopWebInterfaceSite"
        case oopWebInterfaceAPIToken = "oopWebInterfaceAPIToken"
        // Standard algorithm with just constant slope and offset
        case glucoseSlope = "bloodGlucoseSlope"
        case glucoseOffset = "bloodGlucoseOffset"
        // Temperature compensation algorithm
        case useTemperatureAlgorithm = "useTemperatureAlgorithm"
//        case temperatureParameters = "temperatureParameters"
        case DerivedAlgorithmParameters = "DerivedAlgorithmParameters"
//        case additionalSlope = "additionalSlope"
//        case additionalOffset = "additionalOffset"
    }
//    let bloodGlucoseOffset = Double(truncating: aNumber)
//    UserDefaults.standard.set(bloodGlucoseOffset, forKey: "bloodGlucoseOffset")

    // MARK: - temperature compensation algorithm
    
    var useTemperatureAlgorithm: Bool {
        get {
            return bool(forKey: Key.useTemperatureAlgorithm.rawValue)
        }
        set {
            set(newValue, forKey: Key.useTemperatureAlgorithm.rawValue)
        }
    }

    var temperatureParameters: TemperatureAlgorithmParameters? {
        set {
            if let parameters = newValue {
                let aString = serializeAlgorithmParameters(parameters)
                print(aString)
                set(aString, forKey: Key.DerivedAlgorithmParameters.rawValue)
//                UserDefaults.standard.set(aString, forKey: "DerivedAlgorithmParameters")
            }
        }
        get {
            if let aString = UserDefaults.standard.string(forKey: Key.DerivedAlgorithmParameters.rawValue) {
//                if let aString = UserDefaults.standard.string(forKey: "DerivedAlgorithmParameters") {
                return deserializeAlgorithmParameters(text: aString)
            }
            return nil
        }
    }
    
    private func serializeAlgorithmParameters(_ params: TemperatureAlgorithmParameters) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        var aString = ""
        do {
            let jsonData = try encoder.encode(params)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                aString = jsonString
            }
        } catch {
            print("Could not serialize parameters: \(error.localizedDescription)")
        }
        return aString
    }
    
    private func deserializeAlgorithmParameters(text: String) -> TemperatureAlgorithmParameters? {
        
        if let jsonData = text.data(using: .utf8) {
            let decoder = JSONDecoder()
            
            do {
                let parameters = try decoder.decode(TemperatureAlgorithmParameters.self, from: jsonData)
                
                return parameters
            } catch {
                print("Could not create instance: \(error.localizedDescription)")
            }
        } else {
            print("Did not create instance")
        }
        return nil
    }

    
    
    
    
    
//    var additionalSlope: Double {
//        get {
//            return double(forKey: Key.additionalSlope.rawValue)
//        }
//        set {
//            set(newValue, forKey: Key.additionalSlope.rawValue)
//        }
//    }
//    var additionalOffset: Double {
//        get {
//            return double(forKey: Key.additionalOffset.rawValue)
//        }
//        set {
//            set(newValue, forKey: Key.additionalOffset.rawValue)
//        }
//    }


    // MARK: - Standard algorithm with just constant slope and offset
    
    var glucoseSlope: Double {
        get {
            return double(forKey: Key.glucoseSlope.rawValue)
        }
        set {
            set(newValue, forKey: Key.glucoseSlope.rawValue)
        }
    }
    var glucoseOffset: Double {
        get {
            return double(forKey: Key.glucoseOffset.rawValue)
        }
        set {
            set(newValue, forKey: Key.glucoseOffset.rawValue)
        }
    }

    // MARK: - Nightscout
    
    var uploadToNightscoutIsActivated: Bool {
        get {
            return bool(forKey: Key.uploadToNightscoutIsActivated.rawValue)
        }
        set {
            set(newValue, forKey: Key.uploadToNightscoutIsActivated.rawValue)
        }
    }
    var nightscoutSite: String? {
        get {
            return string(forKey: Key.nightscoutSite.rawValue)
        }
        set {
            set(newValue, forKey: Key.nightscoutSite.rawValue)
        }
    }
    var nightscoutAPISecret: String? {
        get {
            return string(forKey: Key.nightscoutAPISecret.rawValue)
        }
        set {
            set(newValue, forKey: Key.nightscoutAPISecret.rawValue)
        }
    }
    
    


    // MARK: - OOP Web interface
    
    var oopWebInterfaceIsActivated: Bool {
        get {
            return bool(forKey: Key.oopWebInterfaceIsActivated.rawValue)
        }
        set {
            set(newValue, forKey: Key.oopWebInterfaceIsActivated.rawValue)
        }
    }
    var oopWebInterfaceSite: String? {
        get {
            return string(forKey: Key.oopWebInterfaceSite.rawValue)
        }
        set {
            set(newValue, forKey: Key.oopWebInterfaceSite.rawValue)
        }
    }
    var oopWebInterfaceAPIToken: String? {
        get {
            return string(forKey: Key.oopWebInterfaceAPIToken.rawValue)
        }
        set {
            set(newValue, forKey: Key.oopWebInterfaceAPIToken.rawValue)
        }
    }
    
    
}
