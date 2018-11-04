//
//  AlgorithmTester.swift
//  SwitftOOPWeb
//
//  Created by Bjørn Inge Berg on 18.10.2018.
//  Copyright © 2018 Bjørn Inge Berg. All rights reserved.
//

import Foundation

fileprivate func writeGlucoseResult(folder: String, filename:String, result: String){
    let fm = FileManager.default
    let dir: URL
    do{
        dir = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
    }catch{
        print("could not write glucoseresult: dir not created")
        return
    }
    
    var isDir: ObjCBool = true
    let subfolder = dir.appendingPathComponent(folder, isDirectory: true)
    if !fm.fileExists(atPath: subfolder.path, isDirectory: &isDir) {
        do{
            try fm.createDirectory(at: subfolder, withIntermediateDirectories: true, attributes: nil)
        } catch{
            print("subfolder could not be created, aborting writing glucose result")
            return
        }
    }
    
    let fileUrl = subfolder.appendingPathComponent(filename)
    print("Saving glucose result to \(fileUrl.path)")
    let finalResult = "\(result)\n"
    
    do {
        try finalResult.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        print("Could not write result: \(error.localizedDescription)")
    }
}

//
// Secondary entrypoint. Call this function if you have already saved parameters to file and want to test with a few values
//
func TestAlgorithm(){
    
    let runner = DerivedAlgorithmRunner.CreateInstanceFromParamsFile()
    if let runner = runner {
        print("Created runner successfully")
        
        //control
        let res1 = runner.GetGlucoseValue(from_raw_glucose: 1500, raw_temp: 7124) // 146.04347826086956
        print("res1: \(res1)")
        
        
        //uwe:58, me: 57, derivedalgo: 57
        let resb1 = runner.GetGlucoseValue(from_raw_glucose: 700, raw_temp: 7124)
        print("res1b: \(resb1)")
        
        //uwe: 318, me: 313, derivedalgo: 313
        let resb2 = runner.GetGlucoseValue(from_raw_glucose: 3000, raw_temp: 7124)
        print("resb2: \(resb2)")
        
        
    } else {
        print("Could not create runner")
    }
    
}

struct SensorReading{
    public var glucose: Int
    public var temperature: Int
    public var nr: Int //for debugging only
    public var sensordata : [UInt8]
    
}


fileprivate func extensiveAlgorithmTestDelegate(runner:DerivedAlgorithmRunner, patch: SensorReading ) {
    
    
    print("processing patch \(patch.nr)")
    
    let client = LibreOOPClient(accessToken: LibreUtils.accessToken)
    
    
    
    client.uploadReading(reading: patch.sensordata ) { (response, success, errormessage)  in
        if(!success) {
            NSLog("remote: upload reading failed! \(errormessage)")
            
            return
        }
        
        if let response = response, let uuid = response.result?.uuid {
            print("uuid received: " + uuid)
            client.getStatusIntervalled(uuid: uuid, { (success, errormessage, oopCurrentValue, newState) in
                
                NSLog("GetStatusIntervalled returned with success?: \(success), error: \(errormessage), response: \(String(describing: oopCurrentValue))), newState: \(newState)")
                //NSLog("GetStatusIntervalled  newState: \(newState)")
                
                var res1 = "Uknown"
                var diff = "Uknown"
                
                let res2 = runner.GetGlucoseValue(from_raw_glucose: patch.glucose, raw_temp: patch.temperature)
                
                if let bg = oopCurrentValue?.currentBg {
                    res1 = "\(bg)"
                    diff = "\(bg - res2)"
                }
                
                
                
                let csvline = "\(patch.glucose)|\(patch.temperature)|\(res1)|\(res2)|\(diff)"
                writeGlucoseResult(folder: "GlucoseComparison", filename: "nr\(patch.nr).txt", result: csvline)
                
                
            })
        } else {
            print("getparsedresult failed")
            
        }
        
        
    }
    
}

func extensiveAlgorithmTest(){
    let runner = DerivedAlgorithmRunner.CreateInstanceFromParamsFile()
    if let runner = runner {
        print("Created runner successfully")
        
        var patches = GenerateFakePatches()
        
        //we don't want to send more than 15 calls to the algorithm per 30 seconds
        //so group them by 15 and delay them
        
        let step = 15
        let start = 0
        
        let delay = 40 //seconds
        var groupdelay = 0
        
        //headers
        writeGlucoseResult(folder: "GlucoseComparison", filename: "000_headers.txt", result: "rawglucose|rawtemperature|oopalgoresult|derivedalgoresult|resultdiff")
        
        for patchrangestart in stride(from: start, to:patches.count, by: step){
            let patchrangeend = min(patchrangestart+step,  patches.count)
            //print("start: \(patchrangestart)")
            let relevantPatches = patches[patchrangestart..<patchrangeend]
            //print("relevant patches: \(relevantPatches)\n")
            
            //print("will send patches \(relevantPatches.first!.nr)-\(relevantPatches.last!.nr) with delay of \(groupdelay) seconds")
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(groupdelay)) { [relevantPatches, runner] in
                
                //print("async: will send patches \(relevantPatches.first!.nr)-\(relevantPatches.last!.nr) with delay of \(groupdelay) seconds")
                
                for  patch in relevantPatches{
                    extensiveAlgorithmTestDelegate(runner: runner, patch: patch)
                    
                }
                
                
                
            }
            
            groupdelay += delay
            
        }
        let now = Date()
        let expectedRuntime = (groupdelay+delay)
        let expectedEndDate = now + TimeInterval(exactly: expectedRuntime)!
        print("time is now \(now), script execution will take about \(expectedRuntime) seconds and be complete about \(expectedEndDate )")
        
    } else {
        print("Could not create runner")
    }
    
}
