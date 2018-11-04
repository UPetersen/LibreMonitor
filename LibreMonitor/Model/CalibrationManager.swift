//
//  CalibrationManager.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 03.11.18.
//  Copyright © 2018 Uwe Petersen. All rights reserved.
//

import Foundation

struct DerivedAlgorithmParameterSet: Codable, CustomStringConvertible {
    // uuid of the sensor which has to be tied to the parameters
//    var serialNumber: String
    var date = Date()
    
    // Parameters for temperature compensation algo, see here: https://github.com/UPetersen/LibreMonitor/wiki/Libre-OOP-Investigation#variation-of-temperature
    var slope_slope: Double
    var offset_slope: Double
    var slope_offset: Double
    var offset_offset: Double
    var isValidForFooterWithReverseCRCs: Int

    
    // Additional slope put on top of the algo to compensate for sensors that e.g. continiously deliver too low values
    var additionalSlope: Double
    // Additional offset put on top of the algo to compensate for sensors that e.g. continiously deliver too low values
    var additionalOffset: Double
    
//    init(serialNumber: String, slope_slope: Double, offset_slope: Double, slope_offset: Double, offset_offset: Double, additionalSlope: Double, additionalOffset:
    init(slope_slope: Double, offset_slope: Double, slope_offset: Double, offset_offset: Double, additionalSlope: Double, additionalOffset: Double, isValidForFooterWithReverseCRCs: Int) {
//        self.serialNumber = serialNumber
        self.slope_slope = slope_slope
        self.offset_slope = offset_slope
        self.slope_offset = slope_offset
        self.offset_offset = offset_offset
        self.additionalSlope = additionalSlope
        self.additionalOffset = additionalOffset
        self.isValidForFooterWithReverseCRCs = isValidForFooterWithReverseCRCs
    }
    
    var description: String {
//        return "Parameters for sensor with serial number '\(serialNumber)' created on \(date.description) \nSlope_slope:   \(slope_slope) \nOffset_slope:  \(offset_slope) \nSlope_offset:  \(slope_offset) \nOffset_offset: \(offset_offset) \nAdditional slope:  \(additionalSlope) \nAdditional offset: \(additionalOffset)"
        return "Parameters created on \(date.description) \nSlope_slope:   \(slope_slope) \nOffset_slope:  \(offset_slope) \nSlope_offset:  \(slope_offset) \nOffset_offset: \(offset_offset) \nAdditional slope:  \(additionalSlope) \nAdditional offset: \(additionalOffset) for sensor with footer crc \(isValidForFooterWithReverseCRCs)"
    }
}

class CalibrationManager {
    var calibrationParameters: DerivedAlgorithmParameterSet? {
        set {
            if let parameters = newValue {
                let aString = serializeAlgorithmParameters(parameters)
                print(aString)
                UserDefaults.standard.set(aString, forKey: "DerivedAlgorithmParameters")
            }
        }
        get {
            if let aString = UserDefaults.standard.string(forKey: "DerivedAlgorithmParameters") {
                return deserializeAlgorithmParameters(text: aString)
            }
            return nil
        }
    }
    
    private func serializeAlgorithmParameters(_ params: DerivedAlgorithmParameterSet) -> String {
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
    
    private func deserializeAlgorithmParameters(text: String) -> DerivedAlgorithmParameterSet? {
        
        if let jsonData = text.data(using: .utf8) {
            let decoder = JSONDecoder()
            
            do {
                let parameters = try decoder.decode(DerivedAlgorithmParameterSet.self, from: jsonData)
                
                return parameters
            } catch {
                print("Could not create instance: \(error.localizedDescription)")
            }
        } else {
            print("Did not create instance")
        }
        return nil
    }
//
//    init(deriveAlgorithmParameterSet: DerivedAlgorithmParameterSet) {
//        self.derivedAlgorithmParameterSet = derivedAlgorithmParameterSet
//    }
//
////    public static func createInstanceFromUserDefaults() -> CalibrationManager? {
////
////    }
}
