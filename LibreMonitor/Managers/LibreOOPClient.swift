//
//  RemoteBG.swift
//  SwitftOOPWeb
//
//  Created by Bjørn Inge Berg on 08.04.2018.
//  Copyright © 2018 Bjørn Inge Berg. All rights reserved.
//

import Foundation
class LibreOOPClient{
    
    private var accessToken: String
    private var uploadEndpoint: String // = "https://libreoopweb.azurewebsites.net/api/CreateRequestAsync"
    private var statusEndpoint: String // = "https://libreoopweb.azurewebsites.net/api/GetStatus"
        
    init(accessToken: String, site: String = "https://libreoopweb.azurewebsites.net") {
        self.accessToken = accessToken
        uploadEndpoint = site + "/api/CreateRequestAsync"
        statusEndpoint = site + "/api/GetStatus"
    }
    
    private static func readingToString(_ a: [UInt8]) -> String{
        return Data(a).base64EncodedString();
    }
    private func postToServer(_ completion:@escaping (( _ data_: Data, _ response: String, _ success: Bool )-> Void), postURL: String, postparams: [String : String]) {
        
        let request = NSMutableURLRequest(url: NSURL(string: postURL)! as URL)
        request.httpMethod = "POST"
        
        
        request.setBodyContent(contentMap: postparams)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            guard let data = data else {
                completion("network error".data(using: .utf8)!, "network error", false)
                return
            }
            
            if let response = String(data: data, encoding: String.Encoding.utf8) {
                completion(data, response, true)
            }
            
        }
        task.resume()
        
        
        
    }
    
    public func getStatusIntervalled(uuid: String, intervalSeconds:UInt32=10, maxTries: Int8=6, _ completion:@escaping ((  _ success: Bool, _ message: String, _ response: String )-> Void)) {
        let q = DispatchQueue.global()
        let sem = DispatchSemaphore(value: 0)
        var remoteResponse = "N/A"
        var succeeded = false;
        var error = ""
        q.async  {
            for i in 1...maxTries {
                NSLog("Attempt \(i): Waiting \(intervalSeconds) seconds before calling getstatus")
                sleep(intervalSeconds)
                NSLog("Finished waiting \(intervalSeconds) seconds before calling getstatus")
                if(succeeded) {
                    break
                }
                self.getStatus(uuid: uuid, { (success, errormsg, response) in
                    if(success) {
                        succeeded = true
                        remoteResponse = response!
                    } else {
                        error = errormsg
                    }
                    
                    sem.signal()
                })
                
                sem.wait();
                NSLog("Hey hop, response received: \(remoteResponse) , success: \(succeeded)");
                if(succeeded) {
                    break
                }
                
            }
            
            completion(succeeded,  error, remoteResponse)
            
            
            
        }
    }
    
    private func getStatus(uuid: String, _ completion:@escaping ((  _ success: Bool, _ message: String, _ response: String? )-> Void)){
        postToServer({ (data, response, success) in
            NSLog("getstatus here:" + response)
            if(!success) {
                NSLog("Get status failed")
                completion(false, response, response)
                return
            }
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(LibreOOPResponse.self, from: data)
                NSLog("getstatus result received")
                if let msg = response.message {
                    NSLog("Error sending GetStatus request " + msg)
                    completion(false, "Error sending GetStatus reques" + msg, nil)
                    //failureHandler(msg)
                    return;
                }
                if let resp = response.result, let result2 = resp.result {
                    NSLog("GetStatus returned a valid result:"  + result2)
                    completion(true, "", result2)
                    return
                } else {
                    NSLog("Result was not ready,")
                    completion(false, "Result was not ready", nil)
                    return;
                }
                
            } catch (let error as NSError){
                NSLog("getstatus error decoding:" + error.localizedDescription)
                completion(false, error.localizedDescription, nil)
                return
            }
            
        }, postURL: statusEndpoint, postparams: ["accesstoken": self.accessToken, "uuid": uuid])
    }
    public func uploadReading(reading: [UInt8], _ completion:@escaping (( _ resp: LibreOOPResponse?, _ success: Bool, _ errorMessage: String)-> Void)){
        
        let r = LibreOOPClient.readingToString(reading)
        NSLog("uploading reading! " + r)
        postToServer({ (data, response, success)  in
            NSLog("uploadreading completed with response: " + response)
            if(!success) {
                NSLog("Did not succeed uploading request!")
                completion(nil, false, "network error!?")
                return
            }
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(LibreOOPResponse.self, from: data)
                if let msg = result.message {
                    NSLog("Error sending request " + msg)
                    return;
                }
                
                NSLog("result was successsfully received!")
                completion(result, true, "");
                return;
                
            } catch let error as NSError{
                NSLog("uploadreading error decoding:" + error.localizedDescription)
                completion(nil, false, error.localizedDescription)
                return
            }
            
        }, postURL: uploadEndpoint, postparams: ["accesstoken": self.accessToken, "b64contents": r])
    }
    
}

