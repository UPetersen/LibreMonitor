//
//  CreatePatches.swift
//  SwitftOOPWeb
//
//  Created by Bjørn Inge Berg on 18.10.2018.
//  Copyright © 2018 Bjørn Inge Berg. All rights reserved.
//

import Foundation

func CreateDabearPatch(raw_glucose:UInt16, raw_temp:UInt16) -> [UInt8]{
    
    // This is only used as a starting point
    // I could have used an empty array instead, but then I would have to copy 4 bytes of the body as well
    var temp = LibreOOPDefaults.TestPatchAlwaysReturning63
    
    
    temp[0..<24] = [
        0x2d,0xb7,0xc8,0x15,0x03,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00] //header
    
    temp[320..<343] = [
        0xad,0x71,0x00,0x00,0xda,0x03,0xa3,0x50,
        0x14,0x07,0x96,0x80,0x5a,0x00,0xed,0xa6,
        0x0a,0x81,0x1a,0xe9,0x04,0xae,0x2c, 0x70 ]
    
    return LibreUtils.CreateFakePatch(fromPatch: temp, raw_glucose: raw_glucose, raw_temp: raw_temp)
}

func Create2018_04_07Sensor(raw_glucose:UInt16, raw_temp:UInt16) -> [UInt8]{
    
    let b64 = "oUroDwMAAAAAAAAAAAAAAAAAAAAAAAAANNYBHaIFyCxagHkFyHhagH8FyGBagIAFyGBagIQFyFBagIIFiEZagIUFyDxagIYFyFhagIQFyEhagIcFyDxagIYFyDxagIwFyDBagI0FyDAagIwFyDQagJUFyERagJ0FyDgagPcCyOBagJACyNibgFkCyHRbgI4CyBRbgBEDyLQZgOgCyIAZgIkCyGiagKICyHRagCQDyFxagHgDyKhagLMDyIyagMkDyJQagAQEyLhagCwEyNBagLUEyAwagHEEyMRagAQEyHhagN8DyKRagJ4DyDhagEYDyEhbgOYCyKhbgB4DyMxagIcDyFSbgJcDyKBagMQDyPyagPYDyAycgHAEyERbgPkEyIybgH8FyGBagGIDyGBagGkDyFQagEEDyKxZAMIQAABvcQAB3wZOURQHloBaAO2mEpAayARTOW8="
    
    let temp : [UInt8] = b64.base64Decoded()!
    return LibreUtils.CreateFakePatch(fromPatch: temp, raw_glucose: raw_glucose, raw_temp: raw_temp)
    
}

func Create_2018_04_21_Sensor(raw_glucose:UInt16, raw_temp:UInt16) -> [UInt8]{
    
    let b64 = "Cs4QFgQAAAAAAAAAAAAAAAAAAAAAAAAAAykIEGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbAGwHyNRbANkRAABywgAIggUJURQHloBaAO2mDm4ayATdWG0="
    
    let temp : [UInt8] = b64.base64Decoded()!
    return LibreUtils.CreateFakePatch(fromPatch: temp, raw_glucose: raw_glucose, raw_temp: raw_temp)
    
}

func Create_2018_06_09_Sensor(raw_glucose:UInt16, raw_temp:UInt16) -> [UInt8]{
    
    let b64 = "zKlYFgMAAAAAAAAAAAAAAAAAAAAAAAAAFYAEHjYDyPwagS0DyPwagR4DyNzagBQDyMwagfwDyGgbge4DyGgbgdsDyFAbgdoDyDwbgcUDyCgbgagDyAwbgYoDyAgbgYIDyPgagXcDyAQbgWYDyPQagVIDyOQagT8DyPQagXsDyAAZgWgEyHgZge8EyEAZgcgEyAwZgawFyHgZgW4FyNgZgeMDyEAagWsDyFwagc0DyMwZgfQDyPAZgc8DyCAZgfUDyGTZgIcEyBwZgUMFyPDYgJMGyCgZgeQGyITZgF0HyMwYgWYHyJDYgJYHyDQagScHyIAagaUHyNwZgakIyEjZgKMIyATZgMoHyPzZgDAHyCwagVwGyEDagHQFyFAagasEyIAagRcEyIgbgSoDyPwagTkCyJQZgTsCyJAZgUUnAADqVwABAwcFURQHloBaAO2mEHcayATNqXE="
    
    let temp : [UInt8] = b64.base64Decoded()!
    return LibreUtils.CreateFakePatch(fromPatch: temp, raw_glucose: raw_glucose, raw_temp: raw_temp)
    
}

func Create_2018_08_14_Sensor(raw_glucose:UInt16, raw_temp:UInt16) -> [UInt8]{
    
    let b64 = "p/g4FQMAAAAAAAAAAAAAAAAAAAAAAAAA+4MAAH4DyHRXAn4DyIiXAoMDyJyXAosDyKSXApADyKRXApEDyKyXApkDyLCXAp8DyLiXAqMDyMCXArADyMRXAqwDyMxXAq0DyNSXArEDyLhXAs4DyJyXAtQDyLyXAtsDyMyXAhwEyIzVAvkDyHCWAvADyFAVAwsEyKhWAngDyARXAl0DyBiYAjEDyCyYAh8DyPCWAgwDyHiWAuYCyJiWAuUCyGiWAicDyEjVAisDyFjVAhgDyDjVAhMDyNQUA/QCyHQUA/ACyBjVAtACyCDVAgsDyBQVA8sCyPCWAh8DyKTZATwDyGzaAXEDyCTaAZADyBTaAZ0DyPRXAs4DyNhWAlEDyByXAjwDyFzVAlADyNSVAnADyPhWAkUDyMCWAn4DyHBXAtEwAADISAABBgcYURQHloBaAO2mAG4ayASz2GI="
    
    let temp : [UInt8] = b64.base64Decoded()!
    return LibreUtils.CreateFakePatch(fromPatch: temp, raw_glucose: raw_glucose, raw_temp: raw_temp)
    
}

func Create_2018_09_02_Sensor(raw_glucose:UInt16, raw_temp:UInt16) -> [UInt8]{
    
    let b64 = "p/g4FQMAAAAAAAAAAAAAAAAAAAAAAAAANkgBH4gCyKyWArQCyExXArYCyECXArECyCxXAq8CyCCXAqoCyBSXAqYCyAiXAqACyPiWAp8CyPCWApwCyOSWApcCyNyWApUCyNSWApACyMiWAo0CyMSWAowCyLiWAooCyLSWAo8CyHRXAmsCyKhXAkACyPBXAlMCyMhXAtACyMhXAqACyLRXAmgCyKhXAj8CyLBXAjcCyNxXAiQCyLxXAi0CyPhXAo0DyNhXAjcEyGBYAo0EyDxYArIEyNhXAt8EyLRXAt8EyCyXAuMEyPiWAvkEyLSWAs8EyJyWAo8EyISWAlcEyISWAhIEyKSWAsEDyFCXAjgDyJRXAlMCyMBXAvcByDSYAsoByOBXAhsCyISXAsIByKiWAqICyFxXArMCyExXAqJQAAAW5QABBgf9UBQHloBaAO2mAEAayAS16GY="
    
    let temp : [UInt8] = b64.base64Decoded()!
    return LibreUtils.CreateFakePatch(fromPatch: temp, raw_glucose: raw_glucose, raw_temp: raw_temp)
    
}

func Create_2018_10_07_Sensor(raw_glucose:UInt16, raw_temp:UInt16) -> [UInt8]{
    
    let b64 = "hNtgFwMAAAAAAAAAAAAAAAAAAAAAAAAA+SIECI4EyPRXAKIEyOxXALUEyORXAMgEyNxXADEEyJBYADEEyIBYADEEyGxYADIEyFxYADUEyFBYADoEyEBYAEEEyDRYAEgEyChYAFIEyCBYAF4EyBRYAG4EyAxYAH4EyABYANwEyIhZAEUEyHRZAJoDyExZAEwDyFBZAEsDyMRZAKUDyOwZgLADyAhaADMEyFxYACgFyKRZAC0FyExaAN0EyCQbgKMEyLxZAAQEyPgagK4DyChaAKwDyMRZAAkEyAhZACAEyGRZAOsDyGBZACQEyJhZAPQDyPwagP0DyPBZABMEyLwbgBoEyDgbgK8DyPBbAIkDiOYbgP4DiHJdgL0EyNwbgCIGyNQagLIHyDwagFYHyORZAGoGyMBZACoFyKhZACUGAACWLgABYwddURQHloBaAO2mEHoayATReG4="
    
    let temp : [UInt8] = b64.base64Decoded()!
    return LibreUtils.CreateFakePatch(fromPatch: temp, raw_glucose: raw_glucose, raw_temp: raw_temp)
    
}

func Create_2018_10_23_Sensor(raw_glucose:UInt16, raw_temp:UInt16) -> [UInt8]{
    let b64 = "UHqIEwMAAAAAAAAAAAAAAAAAAAAAAAAAEdgHAV0FyJxYgFgFyJwYgFQFyJhYgFQFyJwYgFoFyLhYgLYFyNRYgLMFyNxYgI0FyIhYgI8FyKxYgI8FyLRYgH8FyKQYgHoFyKhYgHgFyKhYgHAFyJgYgGcFyLBYgGAFyKhYgGgFyLBYgCYGyBBagJsFyCBagNAEyNxZgC8EyORZgJoDyIhZgBADyLBZgJwCyDxagFUCyMRZgPkCyKxZgIcDyIRZgIgDyGRZgEoDyIxZgDwDyMxZgNkCyCRagJ0CyLxZgHcCyHxZgMgCyGBZgBsDyPxZgGMDyMRZgKYDyDRagNwCyNhZgIwCyJhYgMcCyOBYgIQCyMxYgOwCyHRYgKIDyDgYgFUEyCxYgIIEyEhYgAkFyGwXgFwFyPRXgE0FiLJYgHgYAAB5twABwQcbURQHloBaAO2mEHQayAQN2Wg="
    let temp = b64.base64Decoded()!
    return LibreUtils.CreateFakePatch(fromPatch: temp, raw_glucose: raw_glucose, raw_temp: raw_temp)
}

func CreateOnePatch(raw_glucose:UInt16, raw_temp:UInt16) -> [UInt8] {
    let choosenPatch = Create_2018_10_23_Sensor
    //Create_2018_06_09_Sensor
        //Create_2018_08_14_Sensor
        //Create_2018_08_14_Sensor
        // done: Create_2018_04_21_Sensor
        //done: Create_2018_06_09_Sensor
        //done: Create_2018_08_14_Sensor
        // done: Create_2018_09_02_Sensor
        //done: Create_2018_10_07_Sensor
    
    print("Create patch from \(choosenPatch)")
    return choosenPatch(raw_glucose, raw_temp)
}


func GenerateFakePatches() -> [SensorReading]{
    
    let glucosestart = 1000
    let glucoseend = 3000
    let glucosestep = 20
    
    let tempstart = 6000
    let tempend = 9000
    let tempstep = 20 //default: 100
    var patches = [SensorReading]()
    
    var i=0
    for g in stride(from: glucosestart, through:glucoseend, by: glucosestep){
        for t in stride(from: tempstart, through:tempend, by: tempstep){
            print("Will generate fakepatch for rawglucose \(g) and rawtemperature \(t)")
            patches.append(SensorReading(glucose: g, temperature: t, nr: i, sensordata: CreateOnePatch(raw_glucose: UInt16(g), raw_temp: UInt16(t))))
            i+=1
        }
    }
    
    print("Generated \(i) or \(patches.count) fake patches")
    return patches
    
}

