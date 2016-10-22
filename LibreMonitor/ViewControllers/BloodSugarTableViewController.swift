//
//  TableViewController.swift
//
//  Created by Uwe Petersen on 01.02.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation

import UIKit
import CoreBluetooth
import CoreData
import UserNotifications


class BloodSugarTableViewController: UITableViewController, SimbleeManagerDelegate {
    
    var coreDataStack = CoreDataStack()
    var simbleeManager = SimbleeManager()
    
    var sensorData: SensorData?
    var trendMeasurements: [Measurement]?
    var historyMeasurements: [Measurement]?
    var batteryVoltage = 0.0
    
    var bloodGlucoseOffset: Double!
    var bloodGlucoseSlope: Double!
    var sensor: LibreSensor?
    

    var deviceID = "-"
    var temperatureString = "_"
    
    var timeInMinutesSinceStartOfSensor = 0
    var timeOfLastScan = Date()
    var transmissionDuration = TimeInterval()
    var timeOfTransmissionStart = Date()
    
    
    var dateFormatter = DateFormatter()
    var timeFormatter = DateFormatter()
    
    var notificationTimer = Timer()
    var showNotification = true
    
    
    /// Enum for the sections of this table view
    fileprivate enum Section: Int {
        case connectionData, generalData, graph, trendData, historyData
        /// Count of enum cases (has to be adjusted to this/each very enum)
        /// Source: http://stackoverflow.com/questions/27094878/how-do-i-get-the-count-of-a-swift-enum
        static let count: Int = {
            var max: Int = 0
            while let _ = Section(rawValue: max) { max += 1 }
            return max
        }()
    }
    
    
    @IBAction func doRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        tableView.reloadData()
    }
    
    // MARK: - View Controller life ciycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // self.navigationItem.leftBarButtonItem = self.editButtonItem()
        simbleeManager.delegate = self
        self.title = "LibreMonitor"
        
        let connectButtonTitle = connectButtonTitleForState(simbleeManager.state)
        let conncectButton = UIBarButtonItem(title: connectButtonTitle, style: .plain, target: self, action: #selector(BloodSugarTableViewController.didTapConnectButton))
        self.navigationItem.rightBarButtonItem = conncectButton
        
        bloodGlucoseOffset = UserDefaults.standard.double(forKey: "bloodGlucoseOffset")
        bloodGlucoseSlope = UserDefaults.standard.double(forKey: "bloodGlucoseSlope")
        if bloodGlucoseSlope <= 0.00001 {
            bloodGlucoseSlope = 1.0
            UserDefaults.standard.set(bloodGlucoseSlope, forKey: "bloodGlucoseSlope")
        }
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "HH:mm:ss"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bloodGlucoseOffset = UserDefaults.standard.double(forKey: "bloodGlucoseOffset")
        bloodGlucoseSlope = UserDefaults.standard.double(forKey: "bloodGlucoseSlope")
        
        // Notification for updating table view after application did become active again
        NotificationCenter.default.addObserver(self, selector: #selector(BloodSugarTableViewController.updateTableView), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        // Notification for updating table view after having changed the offset and/of slope
        NotificationCenter.default.addObserver(self, selector: #selector(BloodSugarTableViewController.updateTableView), name: NSNotification.Name(rawValue: "updateBloodSugarTableViewController"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        super.viewWillDisappear(true)
    }
    
    func didTapConnectButton() {
        switch (simbleeManager.state) {
        case .Unassigned:
            simbleeManager.scanForSimblee()
        case .Scanning:
            simbleeManager.centralManager.stopScan()
            simbleeManager.state = .Disconnected
        case .Connected, .Connecting, .Notifying:
            simbleeManager.disconnectManually()
        case .Disconnected, .DisconnectedManually:
            simbleeManager.connect()
        }
    }
    
    
    func updateTableView() {
        self.tableView.reloadData()
    }
    

    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .connectionData: return 3
        case .generalData: return 7
        case .graph: return 1
        case .trendData: return 16
        case .historyData: return 32
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).section == 2 {
            
            // Draw graph
            let cell = tableView.dequeueReusableCell(withIdentifier: "BloodSugarGraphTableViewCell", for: indexPath)
            guard let theCell = cell as? BloodSugarGraphViewTableViewCell else {return cell}

            if let trendMeasurements = trendMeasurements, let historyMeasurements = historyMeasurements {
                theCell.lineChartView.trendMeasurements = trendMeasurements
                theCell.lineChartView.historyMeasurements = historyMeasurements
                theCell.lineChartView.setGlucoseCharts(trendMeasurements, historyMeasurements: historyMeasurements)
                theCell.setNeedsDisplay()
                theCell.lineChartView.setNeedsDisplay()
            }
            return theCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            self.configureCell(cell, atIndexPath: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            didTapConnectButton()
        } else if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 2 {
            // ChangeBloodGlucoseAdjustments
            performSegue(withIdentifier: "ChangeBloodGlucoseAdjustments", sender: self)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Connection"
        case 1: return "General data"
        case 2:
            let seconds = (NSDate() as NSDate).timeIntervalSince(timeOfLastScan).truncatingRemainder(dividingBy: 60.0)
            let minutes = (Date().timeIntervalSince(timeOfLastScan) - seconds) / 60.0
            return String(format: "Graph from %2.0f:%02.0f minutes ago", arguments: [minutes, seconds])
        case 3: return "Last 15 minutes"
        case 4: return "Last eight hours"
        case 5: return "Neue Letzte 15 Minuten"
        case 6: return "Neue Letzte 8 Stunden"
        default: return nil
        }
    }
    
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.black
        cell.accessoryType = .none
        
        switch Section(rawValue: (indexPath as NSIndexPath).section)! {
        case .connectionData:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "Simblee status"
                cell.detailTextLabel?.text = simbleeManager.state.rawValue
                cell.backgroundColor = colorForConnectionState()
            case 1:
                cell.textLabel?.text = "Last scan:"
                if let sennsorData = sensorData {
                    cell.detailTextLabel?.text = String(format: "am \(dateFormatter.string(from: sennsorData.date as Date)), um \(timeFormatter.string(from: sennsorData.date as Date)) Uhr, in %.2f s",
                                                        arguments: [transmissionDuration])
                    
                    if Date().timeIntervalSince(sennsorData.date as Date) > 240.0 {
                        cell.backgroundColor = UIColor.red
                    }
                }
            case 2:
                cell.textLabel?.text = "Offset / Slope:"
                cell.detailTextLabel?.text = String(format: "%.0f mg/dl, %.4f", arguments: [bloodGlucoseOffset, bloodGlucoseSlope])
                cell.accessoryType = .disclosureIndicator
            default: break
            }
        case .generalData:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "BM019 ID"
                cell.detailTextLabel?.text = deviceID
            case 1:
                var crcString = String()
                var color = UIColor()
                if let sensorData = sensorData {
                    crcString += ", crcs: \(sensorData.hasValidHeaderCRC), \(sensorData.hasValidBodyCRC), \(sensorData.hasValidFooterCRC)"
                    color = colorForSensorState( (sensorData.hasValidHeaderCRC && sensorData.hasValidBodyCRC && sensorData.hasValidFooterCRC) )
                } else {
                    crcString = ", nil"
                    color = UIColor.lightGray
                }
                cell.textLabel?.text = "Sensor SN"
                if let sensor = sensor {
                    cell.detailTextLabel?.text =  sensor.serialNumber + crcString // + " (" + sensor.prettyUid  + ")"
                } else {
                    cell.detailTextLabel?.text = ""
                }
                cell.backgroundColor = color
                
                
            case 2:
                cell.textLabel?.text = "Environment"
                cell.detailTextLabel?.text = String(format: "%3.1f V", arguments: [batteryVoltage]) + ", " + temperatureString
                if batteryVoltage < 3.0 {
                    cell.backgroundColor = UIColor.orange
                }
            case 3:
                cell.textLabel?.text = "Blocks"
                if let sennsorData = sensorData {
                    cell.detailTextLabel?.text = "Trend: \(sennsorData.nextTrendBlock), history: \(sennsorData.nextHistoryBlock), minutes: \(sennsorData.minutesSinceStart)"
                }
            case 4:
                cell.textLabel?.text = "Glucose"
                
                if let trendMeasurements = trendMeasurements {
                    let currentGlucose = trendMeasurements[0].glucose
                    let longDelta = currentGlucose - trendMeasurements[15].glucose
                    let shortDelta = (currentGlucose - trendMeasurements[8].glucose) * 2.0 * 16.0/15.0
                    let longPrediction = currentGlucose + longDelta
                    let shortPrediction = currentGlucose + shortDelta
                    cell.detailTextLabel?.text = String(format: "%0.0f, Delta: %0.0f (%0.0f), Prognosis: %0.0f (%0.0f)", arguments: [currentGlucose, longDelta, shortDelta, longPrediction, shortPrediction])
                    if longPrediction < 70.0 || shortPrediction < 70.0 || longPrediction > 180.0 || shortPrediction > 180.0 || (abs(longDelta) > 30.0 && abs(shortDelta) > 30.0) {
                        cell.detailTextLabel?.textColor = UIColor.red
                    } else {
                        cell.detailTextLabel?.textColor = UIColor.black
                    }
                }

            case 5:
                cell.textLabel?.text = "Sensor started"
                if let sennsorData = sensorData {
                    let minutes = sennsorData.minutesSinceStart
                    let days = Int( Double(minutes) / 24.0 / 60.0 )
                    let hours = Int( Double(minutes) / 60.0 ) - days*24
                    let minutesRest = minutes - days*24*60 - hours*60
                    cell.detailTextLabel?.text = String(format: "%d day(s), %d hour(s) and %d minute(s) ago", arguments: [days, hours, minutesRest])
                }
//                cell.detailTextLabel?.text = startOfSensorString
            case 6:
                cell.textLabel?.text = "Sensor status"
                if let sennsorData = sensorData {
                    cell.detailTextLabel?.text = sennsorData.state.description
                } else {
                    cell.detailTextLabel?.text = "nil"
                }
            default:
                cell.textLabel?.text = "Something ..."
                cell.detailTextLabel?.text = "... didn't work"
            }
        case .graph:
            break
            
        case .trendData:
            let index = (indexPath as NSIndexPath).row
            if let measurements = trendMeasurements {
                let timeAsString = timeFormatter.string(from: measurements[index].date as Date)
                let dateAsString = dateFormatter.string(from: measurements[index].date as Date)
                
                cell.textLabel?.text = String(format: "%0.1f mg/dl", measurements[index].glucose)
                
                let rawString = String(format: "%0d", measurements[index].rawValue)
//                let temp =  (Int(measurements[index].bytes[4] & 0x0F) << 6) + Int(measurements[index].bytes[3]) >> 2
//                let hugo = Int(measurements[index].bytes[3] & 3)
                let temp =  (Int(measurements[index].bytes[5] & 0x0F) << 8) + Int(measurements[index].bytes[4])
                let hugo = Int(measurements[index].bytes[3])
                cell.detailTextLabel?.text = "\(timeAsString), \(rawString), \(measurements[index].byteString), \(temp), \(hugo), \(dateAsString), \(index)"
            }

        case .historyData:
            let index = (indexPath as NSIndexPath).row
            if let measurements = historyMeasurements {
                let timeAsString = timeFormatter.string(from: measurements[index].date as Date)
                let dateAsString = dateFormatter.string(from: measurements[index].date as Date)
                
                cell.textLabel?.text = String(format: "%0.1f mg/dl", measurements[index].glucose)
                
                let rawString = String(format: "%0d", measurements[index].rawValue)
//                let temp =  (Int(measurements[index].bytes[4] & 0x0F) << 6) + Int(measurements[index].bytes[3]) >> 2
//                let hugo = Int(measurements[index].bytes[3] & 3)
                let temp =  (Int(measurements[index].bytes[5] & 0x0F) << 8) + Int(measurements[index].bytes[4])
                let hugo = Int(measurements[index].bytes[3])
                cell.detailTextLabel?.text = "\(timeAsString), \(rawString), \(measurements[index].byteString), \(temp), \(hugo), \(dateAsString), \(index)"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 2 {
            return CGFloat(300)
        }
        return CGFloat(20)
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(20)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for segue")
        if segue.identifier == "ChangeBloodGlucoseAdjustments" {
            print("Segue ChangeBloodGlucoseAdjustments")
        }
    }
    
    
    // MARK: - SimbleeManagerDelegate 
    
    func simbleeManagerPeripheralStateChanged(_ state: SimbleeManagerState) {
        self.navigationItem.rightBarButtonItem?.title? = connectButtonTitleForState(state)
        
        switch state {
        case .Unassigned, .Connecting, .Connected, .Scanning, .Disconnected, .DisconnectedManually:
            self.triggerNotificationContentForBadgeIcon(value: 0)  // no badge number if not notifying
        case .Notifying:
            break
        }
        tableView.reloadData()
    }
    
    func simbleeManagerReceivedMessage(_ messageIdentifier: UInt16, txFlags: UInt8, payloadData: Data) {
        print("Received SLIP payload with ID = \(messageIdentifier)")

        switch messageIdentifier {
        case 0x2002: // system information data, including UID (e.g. E0:07:A0:00:00:0C:48:BD")
            
            // Convention: System Information data is the first packet sent via bluetooth, thus delete all internal data and reload table view
            
            timeOfTransmissionStart = Date()
            deviceID = "-"
            
            print(payloadData.debugDescription)
            
            var systemInformationData = SystemInformationDataType(uid: (0, 0, 0, 0, 0, 0, 0, 0), resultCode: 0, responseFlags: 0, infoFlags: 0, errorCode: 0)
            (payloadData as NSData).getBytes(&systemInformationData, length: payloadData.count)      // get payload data into corresponding memory -> tuples
            
            print(String(format: "result code %02X", arguments: [systemInformationData.resultCode]))
            print(String(format: "response flags %02X", arguments: [systemInformationData.responseFlags]))
            print(String(format: "info flags %02X", arguments: [systemInformationData.infoFlags]))
            print(String(format: "error code %02X", arguments: [systemInformationData.errorCode]))
            
            let uidString = systemInformationData.uidString()
            sensor = LibreSensor(withUID: uidString)
            
            //  Convention: System Information data is the first packet sent from RFDuino, thus delete all internal data and reload table view
            tableView.reloadData()
            
        case 0x2005: // Battery
            
            var batteryDataPayload = BatteryDataType(voltage: 0, temperature: 0)
            
            (payloadData as NSData).getBytes(&batteryDataPayload, length:payloadData.count)
            batteryVoltage = Double(batteryDataPayload.voltage)
            temperatureString = String(format: "%4.1f °C", arguments: [batteryDataPayload.temperature])
            
        case 0x1007: // all data bytes (all 344 bytes, i.e. 43 blocks)
            print("received all data bytes packet")

            var bytes = [UInt8](repeating: 0, count: 344)
            (payloadData as NSData).getBytes(&bytes, length: 344)
            sensorData = SensorData(bytes: bytes, date: Date())
            if let sennsorData = sensorData {
                trendMeasurements = sennsorData.trendMeasurements(bloodGlucoseOffset, slope: bloodGlucoseSlope)
                historyMeasurements = sennsorData.historyMeasurements(bloodGlucoseOffset, slope: bloodGlucoseSlope)
                notificationForGlucoseMeasurements(trendMeasurements!)

                if let historyMeasurements = historyMeasurements  ,  sennsorData.hasValidBodyCRC && sennsorData.hasValidHeaderCRC && sennsorData.state == .ready {
                   
                    // fetch all records that are newer than the oldest history measurement of the new data
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    let request = BloodGlucose.fetchRequest() as NSFetchRequest<BloodGlucose>
                    do {
                        let fetchedBloodGlucoses = try coreDataStack.managedObjectContext.fetch(request)
                        
                        // loop over all and check if new data exists and store the new data if not yet existent
                        historyMeasurements.forEach({measurement in
                            
                            var storeMeasurement = true
                            
                            // Check if there is already a record stored for the same time
                            for bloodGlucose in fetchedBloodGlucoses {

                                // store value if dates are less than two mintues apart from each other (in either direction)
                                if let bloodGlucoseDate = bloodGlucose.date, abs(bloodGlucoseDate.timeIntervalSince(measurement.date)) < 2.0 * 60.0 {
                                    storeMeasurement = false
                                    break
                                }
                            }
                            // store if there isn't a measurement yet for this time and if it is a possible value (i.e. greater than zero and greater than offset)
                            if storeMeasurement && measurement.glucose > bloodGlucoseOffset && measurement.glucose > 0.0 {
                                if let glucose = NSEntityDescription.insertNewObject(forEntityName: "BloodGlucose", into: coreDataStack.managedObjectContext) as? BloodGlucose {
                                    glucose.date = measurement.date as NSDate?
                                    glucose.bytes = measurement.byteString
                                    glucose.value = measurement.glucose
                                    glucose.dateString = dateFormatter.string(from: measurement.date as Date)
                                }
                            }
                        })
                        coreDataStack.saveContext()
 
                    } catch {
                        fatalError("Failed to fetch BloodGlucose: \(error)")
                    }
                }
                
                
            } else {
                trendMeasurements = nil
                historyMeasurements = nil
            }
            tableView.reloadData()
            
            
        case 0x2001: // IDN data, including device ID, example: RESPONSE CODE: 0 LENGTH: 15, DEVICE ID: 4E 46 43 20 46 53 32 4A 41 53 54 32 0, ROM CRC: 75D2
            
            // Convention: IDN data is the last packet sent via bluetooth
            
            print(payloadData.debugDescription)
            
            var idnData = IDNDataType(resultCode: 0, deviceID: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), romCRC: (0, 0))
            (payloadData as NSData).getBytes(&idnData, length: payloadData.count)      // get payload data into corresponding memory -> tuples
            
            print(String(format: "resultCode %02X", arguments: [idnData.resultCode]))
            
            let deviceIDString = idnData.deviceIDString()
            print(deviceIDString)
            
            self.deviceID = deviceIDString
            
            timeOfLastScan = Date()
            
            transmissionDuration = Date().timeIntervalSince(timeOfTransmissionStart)
            
            // Convention: the idn data is the last packet sent from RFDuino within a cycle, thus reload table view after having received it
            tableView.reloadData()
            
            
        default:
            break
        }
    }
    
    
    // MARK: - Helper functions
    
    func colorForConnectionState() -> UIColor {
        switch (simbleeManager.state) {
        case .Unassigned, .Disconnected, .DisconnectedManually:
            return UIColor.red
        case .Scanning, .Connecting, .Connected:
            return UIColor(red: CGFloat(0.9), green: CGFloat(0.9), blue: CGFloat(1), alpha: CGFloat(1))
        case .Notifying:
            return UIColor.green
        }
    }
    
    func colorForSensorState(_ bool: Bool) -> UIColor {
        if bool == false {
            return UIColor.red
        }
        return UIColor.white
    }
    
    func connectButtonTitleForState(_ state: SimbleeManagerState) -> String {
        switch state {
        case .Unassigned, .Disconnected, .DisconnectedManually:
            return "connect"
        case .Connected, .Connecting, .Scanning, .Notifying:
            return "disconnect"
        }
    }
    
    // MARK: - Notifications and badge icon
    
    func notificationForGlucoseMeasurements(_ trendMeasurements: [Measurement] ) {
        
        let currentGlucose = trendMeasurements[0].glucose
        let longDelta = currentGlucose - trendMeasurements[15].glucose
        let shortDelta = (currentGlucose - trendMeasurements[8].glucose) * 2.0 * 16.0/15.0
        let longPrediction = currentGlucose + longDelta
        let shortPrediction = currentGlucose + shortDelta
        
        // Show alert if conditions are reached
        if ((longPrediction > 0 && (longPrediction < 60.0 || longPrediction > 180.0)) ||
            (shortPrediction > 0 && (shortPrediction < 66.0 || shortPrediction > 180.0)) ||
            (abs(longDelta) > 30.0 && abs(shortDelta) > 30.0)) && showNotification {
            

            let body = String(format: "%0.0f --> %0.0f (%0.0f), Delta: %0.0f (%0.0f)", arguments: [currentGlucose, longPrediction, shortPrediction, longDelta, shortDelta])
            let content = self.notificationContentForBloodSugarWarning(body)
            let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: timeTrigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    // Do something with error
                    print("Error, blood sugar notification could not be triggered due to: \(error)")
                } else {
                    // Request was added successfully
                    print("triggered blood sugar notification")
                }
            }
            
            // timer to hide notification for 10 minutes
            showNotification = false
            notificationTimer = Timer.scheduledTimer(timeInterval: TimeInterval(10.0*60.0), target: self,  selector: #selector(BloodSugarTableViewController.notificationTimerFired), userInfo: nil, repeats: false)
        }
        //        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        self.triggerNotificationContentForBadgeIcon(value: Int(round(longPrediction)))
    }
    
    
    func triggerNotificationContentForBadgeIcon(value: Int) {
        
        UIApplication.shared.applicationIconBadgeNumber = value

//        let content = UNMutableNotificationContent()
//        content.badge = NSNumber(value: value)
//
//        let timeTrigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
//        let request = UNNotificationRequest(identifier: "Badge", content: content, trigger: timeTrigger)
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                // Do something with error
//                print("Error, badge notification could not be triggered due to \(error)")
//            } else {
//                // Request was added successfully
//                print("triggered badge notification")
//            }
//        }
    }
    
    
    /// Returns a UNMutableNotificationContent with a body
    ///
    /// - parameter body: body to be displayd
    ///
    /// - returns: the notification content
    func   notificationContentForBloodSugarWarning(_ body: String) -> UNMutableNotificationContent {
        
        let content = UNMutableNotificationContent()
        content.title = "Glukose beachten"
        content.subtitle = "Notification Subtitle"
        content.body = body
        //        content.badge = 1
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "GLUCOSE_WARNING_CATEGORY"
        content.userInfo = ["UUID": "123456789" ] // assign a unique identifier to the notification so that we can retrieve it later
        return content
    }
    
    
    func notificationTimerFired() {
        showNotification = true
    }
}



