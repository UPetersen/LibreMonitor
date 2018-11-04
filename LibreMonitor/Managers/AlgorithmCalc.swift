//
//  AlgorithmCalc.swift
//  SwitftOOPWeb
//
//  Created by Bjørn Inge Berg on 15.10.2018.
//  Copyright © 2018 Bjørn Inge Berg. All rights reserved.
//
import Foundation



//
// Main entrypoint
// From main.swift, please call CalculateDerivedAlgorithm() once.
// This will use the libreoopweb API's to derive a function. The function parameters are also saved
//  to the file LibreParamsForCurrentSensor.txt in your documents directory
// After running the CalculateDerivedAlgorithm() function once, you can restore the algorithmrunner with the same parameters using
// let runner = DerivedAlgorithmRunner.CreateInstanceFromParamsFile() without needing to run the CalculateDerivedAlgorithm function again.
// the CalculateDerivedAlgorithm() function should only be run once per sensor, or when you need to update how the logic in the calculation works
func CalculateDerivedAlgorithm(){
    
    let GLUCOSE_LOWER_BOUND = 1000
    let GLUCOSE_UPPPER_BOUND = 3000
    
    let RAW_TEMP1 = 6000//5816
    let RAW_TEMP2 = 9000//7124
    
    let UGLUCOSE_LOWER_BOUND = UInt16(GLUCOSE_LOWER_BOUND )
    let UGLUCOSE_UPPPER_BOUND = UInt16(GLUCOSE_UPPPER_BOUND)
    
    let URAW_TEMP1 = UInt16(RAW_TEMP1)
    let URAW_TEMP2 = UInt16(RAW_TEMP2)
    
    let responseb1 = LibreUtils.GetParsedOOPResult( patch: CreateOnePatch(raw_glucose: UGLUCOSE_LOWER_BOUND, raw_temp: URAW_TEMP1))!.currentBg //uwe:58, me: 57
    let responseb2 = LibreUtils.GetParsedOOPResult( patch: CreateOnePatch(raw_glucose: UGLUCOSE_UPPPER_BOUND, raw_temp: URAW_TEMP1))!.currentBg //uwe: 318, me: 313
    
    
    let slope1 = (responseb2 - responseb1) / (Double(GLUCOSE_UPPPER_BOUND) - Double(GLUCOSE_LOWER_BOUND)) // ca 0.1130434783
    let offset1 = responseb2 - (Double(GLUCOSE_UPPPER_BOUND) * slope1) // ca -21.1304349
    // offset1 = 318 - (3000 * 0.1130434783 )
    let responsef1 = LibreUtils.GetParsedOOPResult( patch: CreateOnePatch(raw_glucose: UGLUCOSE_LOWER_BOUND, raw_temp: URAW_TEMP2))!.currentBg // 44
    
    let responsef2 = LibreUtils.GetParsedOOPResult( patch: CreateOnePatch(raw_glucose: UGLUCOSE_UPPPER_BOUND, raw_temp: URAW_TEMP2))!.currentBg //257
    let slope2 = (responsef2 - responsef1) / (Double(GLUCOSE_UPPPER_BOUND) - Double(GLUCOSE_LOWER_BOUND)) // ca 0.09260869565
    //(459-139) / (3000-1000)=0.16
    
    let offset2 = responsef2 - (Double(GLUCOSE_UPPPER_BOUND) * slope2) //
    //459-3000*0,17
    //459-3000*0,16
    //offset2  = 257 - (3000 * 0.09260869565) // ca -20.82608695
    
    //slope calc
    let slope_slope = (slope1 - slope2) / (Double(RAW_TEMP1) - Double(RAW_TEMP2)) // 0.00001562292
    //slope_slope = (0.1130434783 - 0.09260869565) / (7124 - 5816)
    //double check, some very few decimals might be wrong (rounding error?)
    let offset_slope = slope1 - (slope_slope * Double(RAW_TEMP1)) // 0.00174579622
    //slope_offset= 0.1130434783 - (0.00001562292 * 7124)
    //double check some very few decimals might be wrong (rounding error?)
    let slope_offset = (offset1 - offset2) / (Double(RAW_TEMP1) - Double(RAW_TEMP2)) //-0.00023267185
    // slope_offset = (-21,1304347826087 - -20,8261 ) / (7124 - 5816)
    let offset_offset = offset2 - (slope_offset * Double(RAW_TEMP2)) //-19.4728806406
    //offset_offset = -21.1304349 - (-0.00023267185 * 7124)
    
    print("Parameters")
    print("slope1: \(slope1)")
    print("offset1: \(offset1)")
    
    print("slope2: \(slope2)")
    print("offset2: \(offset2)")
    
    print("slope_slope: \(slope_slope)")
    print("slope_offset: \(slope_offset)")
    
    print("offset_slope: \(offset_slope)")
    print("offset_offset: \(offset_offset)")
    
    /* Result:
     Parameters
     slope1: 0.09130434782608696
     offset1: -20.913043478260875
     slope2: 0.11130434782608696
     offset2: -20.913043478260875
     slope_slope: 1.5290519877675845e-05
     slope_offset: -0.0
     offset_slope: 0.0023746842175242366
     offset_offset: -20.913043478260875
     
     */
    
    let params = DerivedAlgorithmParameters(slope_slope: slope_slope, slope_offset: slope_offset, offset_slope: offset_slope, offset_offset: offset_offset, isValidForFooterWithReverseCRCs: 0) //set footer crc to invalid value on purpose for testing
    
    let runner = DerivedAlgorithmRunner(params)
    
    let res1 = runner.GetGlucoseValue(from_raw_glucose: 1500, raw_temp: 7124) // 146.04347826086956

    
    runner.SaveAlgorithmParameters()
    
    print("res1: \(res1)")
    let res2 = runner.GetGlucoseValue(from_raw_glucose: 700, raw_temp: 3000)//
    print("res2: \(res2)")
    //result of getglucosevalue(1500, 7124)
    // (slope_slope * raw_temp + slope_offset) * raw_glucose + (offset_slope * raw_temp + offset_offset)
    
    
    
}

