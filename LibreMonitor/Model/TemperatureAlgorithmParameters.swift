//
//  TemperatureAlgorithmParameters.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 10.11.18.
//  Copyright © 2018 Uwe Petersen. All rights reserved.
//

import Foundation


struct TemperatureAlgorithmParameters: Codable, CustomStringConvertible {
    // Date when parameters were created
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
    
    init(slope_slope: Double, offset_slope: Double, slope_offset: Double, offset_offset: Double, additionalSlope: Double, additionalOffset: Double, isValidForFooterWithReverseCRCs: Int) {
        self.slope_slope = slope_slope
        self.offset_slope = offset_slope
        self.slope_offset = slope_offset
        self.offset_offset = offset_offset
        self.additionalSlope = additionalSlope
        self.additionalOffset = additionalOffset
        self.isValidForFooterWithReverseCRCs = isValidForFooterWithReverseCRCs
    }
    
    var description: String {
        return "Parameters created on \(date.description) \nSlope_slope:   \(slope_slope) \nOffset_slope:  \(offset_slope) \nSlope_offset:  \(slope_offset) \nOffset_offset: \(offset_offset) \nAdditional slope:  \(additionalSlope) \nAdditional offset: \(additionalOffset) \nfor sensor with footer crc \(isValidForFooterWithReverseCRCs)"
    }
}

