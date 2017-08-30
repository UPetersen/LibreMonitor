//
//  NightscoutUploader.swift
//  RileyLink
//
//  Created by Pete Schwamb on 3/9/16.
//  Copyright © 2016 Pete Schwamb. All rights reserved.
//

import UIKit
//import MinimedKit
//import Crypto

public enum UploadError: Error {
    case httpError(status: Int, body: String)
    case missingTimezone
    case invalidResponse(reason: String)
    case unauthorized
}

private let defaultNightscoutEntriesPath = "/api/v1/entries"
private let defaultNightscoutTreatmentPath = "/api/v1/treatments"
private let defaultNightscoutDeviceStatusPath = "/api/v1/devicestatus"
private let defaultNightscoutAuthTestPath = "/api/v1/experiments/test"

public class NightscoutUploader {

//    enum DexcomSensorError: Int {
//        case sensorNotActive = 1
//        case sensorNotCalibrated = 5
//        case badRF = 12
//    }
    
    public var siteURL: URL
    public var apiSecret: String
    
    private(set) var entries = [NightscoutEntry]()
    private(set) var deviceStatuses = [[String: Any]]()
    private(set) var treatmentsQueue = [NightscoutTreatment]()

    private(set) var lastMeterMessageRxTime: Date?
    
    public private(set) var observingPumpEventsSince: Date!

    private(set) var lastStoredTreatmentTimestamp: Date? {
        get {
            return UserDefaults.standard.lastStoredTreatmentTimestamp
        }
        set {
            UserDefaults.standard.lastStoredTreatmentTimestamp = newValue
        }
    }

    public var errorHandler: ((_ error: Error, _ context: String) -> Void)?

    private var dataAccessQueue: DispatchQueue = DispatchQueue(label: "com.rileylink.NightscoutUploadKit.dataAccessQueue", attributes: [])


    public func reset() {
        observingPumpEventsSince = Date(timeIntervalSinceNow: TimeInterval(hours: -24))
        lastStoredTreatmentTimestamp = nil
    }

    public init(siteURL: URL, APISecret: String) {
        self.siteURL = siteURL
        self.apiSecret = APISecret
        
        observingPumpEventsSince = lastStoredTreatmentTimestamp ?? Date(timeIntervalSinceNow: TimeInterval(hours: -24))
    }
    
    // MARK: - Processing data from pump

//    /**
//     Enqueues pump history events for upload, with automatic retry management.
//
//     - parameter events:    An array of timestamped history events. Only types with known Nightscout mappings will be uploaded.
//     - parameter source:    The device identifier to display in Nightscout
//     - parameter pumpModel: The pump model info associated with the events
//     */
//    public func processPumpEvents(_ events: [TimestampedHistoryEvent], source: String, pumpModel: PumpModel) {
//
//        // Find valid event times
//        let newestEventTime = events.last?.date
//
//        // Find the oldest event that might still be updated.
//        var oldestUpdatingEventDate: Date?
//
//        for event in events {
//            switch event.pumpEvent {
//            case let bolus as BolusNormalPumpEvent:
//                let deliveryFinishDate = event.date.addingTimeInterval(bolus.duration)
//                if newestEventTime == nil || deliveryFinishDate.compare(newestEventTime!) == .orderedDescending {
//                    // This event might still be updated.
//                    oldestUpdatingEventDate = event.date
//                    break
//                }
//            default:
//                continue
//            }
//        }
//
//        if oldestUpdatingEventDate != nil {
//            observingPumpEventsSince = oldestUpdatingEventDate!
//        } else if newestEventTime != nil {
//            observingPumpEventsSince = newestEventTime!
//        }
//
//        for treatment in NightscoutPumpEvents.translate(events, eventSource: source) {
//            treatmentsQueue.append(treatment)
//        }
//        self.flushAll()
//    }

//    /**
//     Enqueues pump glucose events for upload, with automatic retry management.
//
//     - parameter events:    An array of timestamped glucose events. Only sensor glucose data will be uploaded.
//     - parameter source:    The device identifier to display in Nightscout
//     */
//    public func processGlucoseEvents(_ events: [TimestampedGlucoseEvent], source: String) -> Date? {
//        for event in events {
//            if let entry = NightscoutEntry(event: event, device: source) {
//                entries.append(entry)
//            }
//        }
//
//        var timestamp: Date? = nil
//
//        if let lastEntry = entries.last {
//            timestamp = lastEntry.timestamp
//        }
//
//        self.flushAll()
//
//        return timestamp
//    }

    /// Attempts to upload nightscout treatment objects.
    /// This method will not retry if the network task failed.
    ///
    /// - parameter treatments:           An array of nightscout treatments.
    /// - parameter completionHandler:    A closure to execute when the task completes. It has a single argument for any error that might have occurred during the upload.
//    public func upload(_ treatments: [NightscoutTreatment], completionHandler: @escaping (Either<[String],Error>) -> Void) {
//        postToNS(treatments.map { $0.dictionaryRepresentation }, endpoint: defaultNightscoutTreatmentPath, completion: completionHandler)
//    }

    /// Attempts to modify nightscout treatments. This method will not retry if the network task failed.
    ///
    /// - parameter treatments:        An array of nightscout treatments. The id attribute must be set, identifying the treatment to update.  Treatments without id will be ignored.
    /// - parameter completionHandler: A closure to execute when the task completes. It has a single argument for any error that might have occurred during the modify.
//    public func modifyTreatments(_ treatments:[NightscoutTreatment], completionHandler: @escaping (Error?) -> Void) {
//        dataAccessQueue.async {
//            let modifyGroup = DispatchGroup()
//            var errors = [Error]()
//
//            for treatment in treatments {
//                guard treatment.id != nil, treatment.id != "NA" else {
//                    continue
//                }
//                modifyGroup.enter()
//                self.putToNS( treatment.dictionaryRepresentation, endpoint: defaultNightscoutTreatmentPath ) { (error) in
//                    if let error = error {
//                        errors.append(error)
//                    }
//                    modifyGroup.leave()
//                }
//            }
//
//            _ = modifyGroup.wait(timeout: DispatchTime.distantFuture)
//            completionHandler(errors.first)
//        }
//
//    }

    /// Attempts to delete treatments from nightscout. This method will not retry if the network task failed.
    ///
    /// - parameter id:                An array of nightscout treatment ids
    /// - parameter completionHandler: A closure to execute when the task completes. It has a single argument for any error that might have occurred during the deletion.
//    public func deleteTreatmentsById(_ ids:[String], completionHandler: @escaping (Error?) -> Void) {
//        dataAccessQueue.async {
//            let deleteGroup = DispatchGroup()
//            var errors = [Error]()
//
//            for id in ids {
//                guard id != "NA" else {
//                    continue
//                }
//                deleteGroup.enter()
//                self.deleteFromNS(id, endpoint: defaultNightscoutTreatmentPath) { (error) in
//                    if let error = error {
//                        errors.append(error)
//                    }
//                    deleteGroup.leave()
//                }
//            }
//
//            _ = deleteGroup.wait(timeout: DispatchTime.distantFuture)
//            completionHandler(errors.first)
//        }
//    }
//
//    public func uploadDeviceStatus(_ status: DeviceStatus) {
//        deviceStatuses.append(status.dictionaryRepresentation)
//        flushAll()
//    }
    
    //  Entries [ { sgv: 375,
    //    date: 1432421525000,
    //    dateString: '2015-05-23T22:52:05.000Z',
    //    trend: 1,
    //    direction: 'DoubleUp',
    //    device: 'share2',
    //    type: 'sgv' } ]
   

//    public func uploadSGVFromMySentryPumpStatus(_ status: MySentryPumpStatusMessageBody, device: String) {
//
//        var recordSGV = true
//        let glucose: Int = {
//            switch status.glucose {
//            case .active(glucose: let glucose):
//                return glucose
//            case .highBG:
//                return 401
//            case .weakSignal:
//                return DexcomSensorError.badRF.rawValue
//            case .meterBGNow, .calError:
//                return DexcomSensorError.sensorNotCalibrated.rawValue
//            case .lost, .missing, .ended, .unknown, .off, .warmup:
//                recordSGV = false
//                return DexcomSensorError.sensorNotActive.rawValue
//            }
//        }()
//
//
//        // Create SGV entry from this mysentry packet
//        if (recordSGV) {
//
//            guard let sensorDateComponents = status.glucoseDateComponents, let sensorDate = sensorDateComponents.date else {
//                return
//            }
//
//            let previousSGV: Int?
//            let previousSGVNotActive: Bool?
//
//            switch status.previousGlucose {
//            case .active(glucose: let previousGlucose):
//                previousSGV = previousGlucose
//                previousSGVNotActive = nil
//            default:
//                previousSGV = nil
//                previousSGVNotActive = true
//            }
//            let direction: String = {
//                switch status.glucoseTrend {
//                case .up:
//                    return "SingleUp"
//                case .upUp:
//                    return "DoubleUp"
//                case .down:
//                    return "SingleDown"
//                case .downDown:
//                    return "DoubleDown"
//                case .flat:
//                    return "Flat"
//                }
//                }()
//
//            let entry = NightscoutEntry(glucose: glucose, timestamp: sensorDate, device: device, glucoseType: .Sensor, previousSGV: previousSGV, previousSGVNotActive: previousSGVNotActive, direction: direction)
//            entries.append(entry)
//        }
//        flushAll()
//    }
    public func uploadTestData() {
        let entry = NightscoutEntry(glucose: 99, timestamp: Date().addingTimeInterval(-3000), device: "aDevice", glucoseType: .Sensor, previousSGV: 98, previousSGVNotActive: false, direction: "Flat")
        entries.append(entry)
        flushEntries()
    }
//    public func handleMeterMessage(_ msg: MeterMessage) {
//
//        // TODO: Should only accept meter messages from specified meter ids.
//        // Need to add an interface to allow user to specify linked meters.
//
//        if msg.ackFlag {
//            return
//        }
//
//        let date = Date()
//
//        // Skip duplicates
//        if lastMeterMessageRxTime == nil || lastMeterMessageRxTime!.timeIntervalSinceNow.minutes < -3 {
//            let entry = NightscoutEntry(glucose: msg.glucose, timestamp: date, device: "Contour Next Link", glucoseType: .Meter)
//            entries.append(entry)
//            lastMeterMessageRxTime = date
//        }
//    }

    // MARK: - Uploading
    
    func flushAll() {
//        flushDeviceStatuses()
        flushEntries()
//        flushTreatments()
        
    }

    func deleteFromNS(_ id: String, endpoint:String, completion: @escaping (Error?) -> Void)  {
        let resource = "\(endpoint)/\(id)"
        callNS(nil, endpoint: resource, method: "DELETE") { (result) in
            switch result {
            case .success( _):
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }

    }

    func putToNS(_ json: Any, endpoint:String, completion: @escaping (Error?) -> Void) {
        callNS(json, endpoint: endpoint, method: "PUT") { (result) in
            switch result {
            case .success( _):
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func postToNS(_ json: [Any], endpoint:String, completion: @escaping (Either<[String],Error>) -> Void) {
        if json.count == 0 {
            completion(.success([]))
            return
        }

        callNS(json, endpoint: endpoint, method: "POST") { (result) in
            switch result {
            case .success(let postResponse):
                guard let insertedEntries = postResponse as? [[String: Any]], insertedEntries.count == json.count else {
                    completion(.failure(UploadError.invalidResponse(reason: "Expected array of \(json.count) objects in JSON response")))
                    return
                }

                let ids = insertedEntries.map({ (entry: [String: Any]) -> String in
                    if let id = entry["_id"] as? String {
                        return id
                    } else {
                        // Upload still succeeded; likely that this is an old version of NS
                        // Instead of failing (which would cause retries later, we just mark
                        // This entry has having an id of 'NA', which will let us consider it
                        // uploaded.
                        //throw UploadError.invalidResponse(reason: "Invalid/missing id in response.")
                        return "NA"
                    }
                })
                completion(.success(ids))
            case .failure(let error):
                completion(.failure(error))
            }

        }
    }

    func callNS(_ json: Any?, endpoint:String, method:String, completion: @escaping (Either<Any,Error>) -> Void) {
        let uploadURL = siteURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: uploadURL)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiSecret.sha1, forHTTPHeaderField: "api-secret")

        do {

            if let json = json {
                let sendData = try JSONSerialization.data(withJSONObject: json, options: [])
                let task = URLSession.shared.uploadTask(with: request, from: sendData, completionHandler: { (data, response, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.failure(UploadError.invalidResponse(reason: "Response is not HTTPURLResponse")))
                        return
                    }

                    if httpResponse.statusCode != 200 {
                        let error = UploadError.httpError(status: httpResponse.statusCode, body:String(data: data!, encoding: String.Encoding.utf8)!)
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data, !data.isEmpty else {
                        completion(.success([]))
                        return
                    }

                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                        completion(.success(json))
                    } catch {
                        completion(.failure(error))
                        return
                    }
                })
                task.resume()
            } else {
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.failure(UploadError.invalidResponse(reason: "Response is not HTTPURLResponse")))
                        return
                    }

                    if httpResponse.statusCode != 200 {
                        let error = UploadError.httpError(status: httpResponse.statusCode, body:String(data: data!, encoding: String.Encoding.utf8)!)
                        completion(.failure(error))
                        return
                    }

                    guard let data = data else {
                        completion(.failure(UploadError.invalidResponse(reason: "No data in response")))
                        return
                    }

                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                        completion(.success(json))
                    } catch {
                        completion(.failure(error))
                        return
                    }
                })
                task.resume()
            }

        } catch let error {
            completion(.failure(error))
        }
    }
    
//    func flushDeviceStatuses() {
//        let inFlight = deviceStatuses
//        deviceStatuses = []
//        postToNS(inFlight as [Any], endpoint: defaultNightscoutDeviceStatusPath) { (result) in
//            switch result {
//            case .failure(let error):
//                self.errorHandler?(error, "Uploading device status")
//                // Requeue
//                self.deviceStatuses.append(contentsOf: inFlight)
//            case .success(_):
//                break
//            }
//        }
//    }
    
    func flushEntries() {
        let inFlight = entries
        entries = []
        postToNS(inFlight.map({$0.dictionaryRepresentation}), endpoint: defaultNightscoutEntriesPath) { (result) in
            switch result {
            case .failure(let error):
                self.errorHandler?(error, "Uploading nightscout entries")
                // Requeue
                self.entries.append(contentsOf: inFlight)
            case .success(_):
                break
            }
        }
    }
    
//    func flushTreatments() {
//        let inFlight = treatmentsQueue
//        treatmentsQueue = []
//        postToNS(inFlight.map({$0.dictionaryRepresentation}), endpoint: defaultNightscoutTreatmentPath) { (result) in
//            switch result {
//            case .failure(let error):
//                self.errorHandler?(error, "Uploading nightscout treatment records")
//                // Requeue
//                self.treatmentsQueue.append(contentsOf: inFlight)
//            case .success(_):
//                if let last = inFlight.last {
//                    self.lastStoredTreatmentTimestamp = last.timestamp
//                }
//            }
//        }
//    }
    
    // Uwe Petersen, 2017-08-30: Introduced as a more simple means to verify connection and credentials.
     func verify(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        self.checkAuth({ (error) in
            if let error = error {
                // self.isAuthorized = false
                completion(false, error)
            } else {
                // self.isAuthorized = true
                completion(true, nil)
            }
        })
    }
    
    public func checkAuth(_ completion: @escaping (Error?) -> Void) {
        
        let testURL = siteURL.appendingPathComponent(defaultNightscoutAuthTestPath)
        
        var request = URLRequest(url: testURL)
        
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue("application/json", forHTTPHeaderField:"Accept")
        request.setValue(apiSecret.sha1, forHTTPHeaderField:"api-secret")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                completion(error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse ,
                httpResponse.statusCode != 200 {
                    if httpResponse.statusCode == 401 {
                        completion(UploadError.unauthorized)
                    } else {
                        let error = UploadError.httpError(status: httpResponse.statusCode, body:String(data: data!, encoding: String.Encoding.utf8)!)
                        completion(error)
                    }
            } else {
                completion(nil)
            }
        })
        task.resume()
    }
}

