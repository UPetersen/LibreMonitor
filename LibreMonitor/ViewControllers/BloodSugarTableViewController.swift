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
import os.log


//final class BloodSugarTableViewController: UITableViewController, SimbleeManagerDelegate, MiaoMiaoManagerDelegate {
final class BloodSugarTableViewController: UITableViewController, MiaoMiaoManagerDelegate {

    // MARK: - Properties
    
    static let bt_log = OSLog(subsystem: "com.LibreMonitor", category: "BloodSugarTableViewController")
    
    var persistentContainer: NSPersistentContainer?
    var miaoMiaoManager: MiaoMiaoManager!

    var uploader: NightscoutUploader?
    private(set) var nightscoutEntries = [NightscoutEntry]()
    
    var sensorData: SensorData?
//    var sensor: SensorData?
    var trendMeasurements: [Measurement]?
    var historyMeasurements: [Measurement]?
    var fetchedGlucoses: [BloodGlucose]?
    var oopCurrentValue: OOPCurrentValue? {
        didSet {
            self.tableView.reloadData()
            print("----------------------- \n\n\n DID SET IT \n\n\n ----------------------------")
//            if let oopCurrentValue = oopCurrentValue {

//                // Store value in core data data base
//                if let currentMeasurement = trendMeasurements?.first {
//                    let glucose = BloodGlucose(context: (persistentContainer?.viewContext)!)
//                    glucose.value = oopCurrentValue.currentBg
//                    glucose.bytes = currentMeasurement.byteString
//                    glucose.date = currentMeasurement.date as NSDate
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                    glucose.dateString = dateFormatter.string(from: currentMeasurement.date)
//
//                    print("trend: \(String(describing: sensorData?.nextTrendBlock)), history: \(String(describing: sensorData?.nextHistoryBlock)); counter: \(String(describing: sensorData?.minutesSinceStart))")
//                    NSLog("Decoded content")
//                    NSLog("  Current trend: \(oopCurrentValue.currentTrend)")
//                    NSLog("  Current bg: \(oopCurrentValue.currentBg)")
//                    NSLog("  Current time: \(oopCurrentValue.currentTime)")
//                    NSLog("  Serial Number: \(oopCurrentValue.serialNumber ?? "-")")
//                    NSLog("  timeStamp: \(oopCurrentValue.timestamp)")
//                    var i = 0
//                    for historyValue in oopCurrentValue.historyValues {
//                        NSLog(String(format: "    #%02d: time: \(historyValue.time), quality: \(historyValue.quality), bg: \(historyValue.bg)", i))
//                        i += 1
//                    }
//
//                    print("----------------------- DID STORE IT in CORE DATA ----------------------------")
//                }
//
//                let request = BloodGlucose.fetchRequest(from: Date(timeIntervalSinceNow: TimeInterval(-30600))) as NSFetchRequest<BloodGlucose> // 8.5 h = 30600 s
//                request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//                if let fetchedGlucoses = try? persistentContainer?.viewContext.fetch(request) {
//                    self.fetchedGlucoses = fetchedGlucoses
//                } else {
//                    self.fetchedGlucoses = nil
//                }
//            }
        }
    }
    
    var timeOfLastScan = Date()
    var timer = Timer() // used to update the display regularly
    
    var dateFormatter = DateFormatter()
    var timeFormatter = DateFormatter()
    
    
    /// Enum for the sections of this table view
    fileprivate enum Section: Int, CaseIterable {
        case connectionData, generalData, graphHeader, graph, trendData, historyData
    }
    
    
    @IBAction func doRefresh(_ sender: UIRefreshControl) {
        if let writeCharacteristic = miaoMiaoManager.writeCharacteristic {
            miaoMiaoManager.peripheral?.writeValue(Data.init(bytes: [0xD3, 0x01]), for: writeCharacteristic, type: .withResponse)
            miaoMiaoManager.rxBuffer = Data()
            miaoMiaoManager.peripheral?.writeValue(Data.init(bytes: [0xF0]), for: writeCharacteristic, type: .withResponse)
        }
        sender.endRefreshing()
        tableView.reloadData()
    }
    
    // MARK: - View Controller life ciycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miaoMiaoManager.delegate = self

        self.navigationItem.title = "LibreMonitor"
        if let site = UserDefaults.standard.nightscoutSite,
            let siteURL = URL.init(string: site),
            let apiSecret = UserDefaults.standard.nightscoutAPISecret {
            uploader = NightscoutUploader(siteURL: siteURL, APISecret: apiSecret)
        }
        
        let connectButtonTitle = connectButtonTitleForMiaoMiaoState(miaoMiaoManager.state)
        let conncectButton = UIBarButtonItem(title: connectButtonTitle, style: .plain, target: self, action: #selector(BloodSugarTableViewController.didTapConnectButton))
        self.navigationItem.rightBarButtonItem = conncectButton
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "HH:mm:ss"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Notification for updating table view after application did become active again
        NotificationCenter.default.addObserver(self, selector: #selector(BloodSugarTableViewController.updateTableView), name: UIApplication.didBecomeActiveNotification, object: nil)
        // Notification for updating table view after having changed the offset and/of slope
        NotificationCenter.default.addObserver(self, selector: #selector(BloodSugarTableViewController.updateTableView), name: NSNotification.Name(rawValue: "updateBloodSugarTableViewController"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        super.viewWillDisappear(true)
        timer.invalidate()
    }
    
    
    @objc func didTapConnectButton() {
        switch (miaoMiaoManager.state) {
        case .Unassigned:
            miaoMiaoManager.scanForMiaoMiao()
        case .Scanning:
            miaoMiaoManager.centralManager.stopScan()
            miaoMiaoManager.state = .Disconnected
        case .Connected, .Connecting, .Notifying:
            miaoMiaoManager.disconnectManually()
        case .Disconnected, .DisconnectingDueToButtonPress:
            miaoMiaoManager.connect()
        }
    }
    
    
    @objc func updateTableView() {
        os_log("Update table view", log: BloodSugarTableViewController.bt_log, type: .default)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        os_log("Did receive memory warning", log: BloodSugarTableViewController.bt_log, type: .default)
        NotificationManager.scheduleApplicationDidReceiveMemoryWarningdNotification()
    }

    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .connectionData: return 3
        case .generalData: return 8
        case .graphHeader: return 0
        case .graph: return 1
        case .trendData: return 16
        case .historyData: return 32
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).section == Section.graph.rawValue {
            
            // Draw graph
            let cell = tableView.dequeueReusableCell(withIdentifier: "BloodSugarGraphTableViewCell", for: indexPath)
            guard let theCell = cell as? BloodSugarGraphViewTableViewCell else {return cell}

            if let trendMeasurements = trendMeasurements, let historyMeasurements = historyMeasurements {
                theCell.lineChartView.trendMeasurements = trendMeasurements
                theCell.lineChartView.historyMeasurements = historyMeasurements
                theCell.lineChartView.oopCurrentValue = oopCurrentValue
                theCell.lineChartView.setGlucoseCharts(trendMeasurements: trendMeasurements, historyMeasurements: historyMeasurements, oopCurrentValue: oopCurrentValue, fetchedGlucoses: fetchedGlucoses)
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

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.connectionData.rawValue:
            return "Connection"
        case Section.generalData.rawValue:
            return "General data"
        case Section.graphHeader.rawValue:
            let seconds = (NSDate() as NSDate).timeIntervalSince(timeOfLastScan).truncatingRemainder(dividingBy: 60.0)
            let minutes = (Date().timeIntervalSince(timeOfLastScan) - seconds) / 60.0
            return String(format: "Graph from %2.0f:%02.0f minutes ago", arguments: [minutes, seconds])
        case Section.graph.rawValue:
            return nil
        case Section.trendData.rawValue:
            return "Last 15 minutes"
        case Section.historyData.rawValue:
            return "Last eight hours"
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
                cell.textLabel?.text = "Miaomiao status"
                cell.detailTextLabel?.text = miaoMiaoManager.state.rawValue
                cell.backgroundColor = colorForConnectionMiaoMiaoState()
            case 1:
                cell.textLabel?.text = "Last scan:"
                if let sensorData = sensorData {
                    cell.detailTextLabel?.text = "\(dateFormatter.string(from: sensorData.date as Date)), at \(timeFormatter.string(from: sensorData.date as Date))"
                    
                    if Date().timeIntervalSince(sensorData.date as Date) > 450.0 {
                        cell.backgroundColor = UIColor.red
                    }
                }
            case 2:
                cell.textLabel?.text = "Offset / Slope:"
                cell.detailTextLabel?.text = String(format: "%.0f mg/dl, %.4f", arguments: [UserDefaults.standard.glucoseOffset, UserDefaults.standard.glucoseSlope])
                cell.accessoryType = .disclosureIndicator
            default: break
            }
        case .generalData:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "Hard-/Firmware"
                if let miaoMiao = miaoMiaoManager.miaoMiao, let responseState = miaoMiaoManager.miaoMiaoResponseState {
                    cell.detailTextLabel?.text = miaoMiao.hardware + "/" + miaoMiao.firmware + ", Response state: " + responseState.description
                } else {
                    cell.detailTextLabel?.text = nil
                }
            case 1:
                var crcString = String()
                var color = UIColor()
                if let sensorData = sensorData {
                    crcString.append(", crcs: \(sensorData.hasValidHeaderCRC), \(sensorData.hasValidBodyCRC), \(sensorData.hasValidFooterCRC)")
                    color = colorForSensorCRCs( (sensorData.hasValidCRCs ))
                } else {
                    crcString = ", nil"
                    color = UIColor.lightGray
                }
                cell.textLabel?.text = "Sensor SN"
                cell.detailTextLabel?.text = (sensorData?.serialNumber ?? "-") + crcString + " " // + " (" + sensor.prettyUid  + ")"
                cell.backgroundColor = color
            case 2:
                cell.textLabel?.text = "Battery"
                cell.detailTextLabel?.text = miaoMiaoManager.miaoMiao?.batteryString ?? ""
                if let miaoMiao = miaoMiaoManager.miaoMiao, miaoMiao.battery < 40 {
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
            case 6:
                cell.textLabel?.text = "Sensor status"
                if let sennsorData = sensorData {
                    cell.detailTextLabel?.text = sennsorData.state.description
                    cell.backgroundColor = colorForSensorState(sensorState: sennsorData.state)
                } else {
                    cell.detailTextLabel?.text = "nil"
                }
            case 7:
                cell.textLabel?.text = "OOP Glucose"

                if let sensorData = sensorData {
                    if let oopCurrentValue = oopCurrentValue {
                        cell.detailTextLabel?.text = "\(oopCurrentValue.currentBg) mg/dl, time: \(oopCurrentValue.currentTime), trend: \(oopCurrentValue.currentTrend) at \(timeFormatter.string(from: sensorData.date))"
                    }
                    if let temperatureAlgorithmParameterSet = sensorData.temperatureAlgorithmParameterSet,
                        sensorData.footerCrc != UInt16(temperatureAlgorithmParameterSet.isValidForFooterWithReverseCRCs).byteSwapped {
                        cell.detailTextLabel?.text?.append(", but parameters do not match current sensor. Get new Parameters?")
                        cell.backgroundColor = UIColor.red
                    } else {
                        cell.backgroundColor = UIColor.white
                    }
                } else {
                    cell.detailTextLabel?.text = "-"
                }
                
            default:
                cell.textLabel?.text = "Something ..."
                cell.detailTextLabel?.text = "... didn't work"
            }
        case .graphHeader:
            break
        case .graph:
            break
            
        case .trendData:
            let index = (indexPath as NSIndexPath).row
            if let measurements = trendMeasurements {
                let timeAsString = timeFormatter.string(from: measurements[index].date as Date)
                let dateAsString = dateFormatter.string(from: measurements[index].date as Date)
                let rawString = String(format: "%0d, %0d", measurements[index].rawGlucose, measurements[index].rawTemperature)

                cell.textLabel?.text = String(format: "%0.1f mg/dl", measurements[index].glucose)
                cell.detailTextLabel?.text = "\(timeAsString), \(rawString), \(measurements[index].byteString), \(dateAsString), \(index)"
            }

        case .historyData:
            let index = (indexPath as NSIndexPath).row
            if let measurements = historyMeasurements {
                let timeAsString = timeFormatter.string(from: measurements[index].date as Date)
                let dateAsString = dateFormatter.string(from: measurements[index].date as Date)
                var rawString = String(format: "%0d, %0d, %0d, %d", measurements[index].rawGlucose, measurements[index].rawTemperature, measurements[index].counter, Int(measurements[index].oopGlucose))
                if let oopCurrentValue = self.oopCurrentValue {
                    let aString = String(format: ", oop: %0d, %0d, %0d", Int(round(oopCurrentValue.historyValues[31-index].bg)), oopCurrentValue.historyValues[31-index].time, oopCurrentValue.historyValues[31-index].quality)
                    rawString.append(aString)
                }
                cell.textLabel?.text = String(format: "%0.1f mg/dl", measurements[index].glucose)
                cell.detailTextLabel?.text = "\(timeAsString), \(rawString), \(measurements[index].byteString), \(dateAsString), \(index)"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == Section.graph.rawValue {
            return CGFloat(300)
        }
        return CGFloat(20)
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(20)
    }
    
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .connectionData:
            if indexPath.row == 0 {
                didTapConnectButton()
            } else if indexPath.row == 2 {
                performSegue(withIdentifier: "ChangeBloodGlucoseAdjustments", sender: self) // ChangeBloodGlucoseAdjustments
            }
        case .trendData, .historyData:
            performSegue(withIdentifier: "showGlucoseCDTVC", sender: self)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeBloodGlucoseAdjustments" {
            print("Segue ChangeBloodGlucoseAdjustments")
        } else if segue.identifier == "showGlucoseCDTVC" {
            if let vc = segue.destination as? GlucoseCDTVC {
                vc.persistentContainer = persistentContainer
            }
        }
    }
    
    
    // MARK: MiaoMiaoManagerDelegate

    func miaoMiaoManagerPeripheralStateChanged(_ state: MiaoMiaoManagerState) {
        os_log("MiaMiao manager peripheral state changed to %{public}@", log: BloodSugarTableViewController.bt_log, type: .default, String(describing: state.rawValue))
        
        self.navigationItem.rightBarButtonItem?.title? = connectButtonTitleForMiaoMiaoState(state)
        
        switch state {
        case .Unassigned, .Connecting, .Connected, .Scanning, .DisconnectingDueToButtonPress, .Disconnected:
            NotificationManager.applicationIconBadgeNumber(value: 0) // Data not accurate any more -> remove badge icon
            NotificationManager.scheduleBluetoothDisconnectedNotification(wait: 450)
        case .Notifying:
            NotificationManager.removePendingBluetoothDisconnectedNotification()
        }
        tableView.reloadData()
    }
    
    func miaoMiaoManagerDidUpdateSensorAndMiaoMiao(sensorData: SensorData, miaoMiao: MiaoMiao) {
        
        self.sensorData = sensorData
        
        resetTimer()
        if sensorData.hasValidCRCs {
            if UserDefaults.standard.oopWebInterfaceIsActivated {
                getOOPGlucose(fram: sensorData.bytes)
            }
            
            timeOfLastScan = Date()
            trendMeasurements = sensorData.trendMeasurements(UserDefaults.standard.glucoseOffset, slope: UserDefaults.standard.glucoseSlope)
            historyMeasurements = sensorData.historyMeasurements(UserDefaults.standard.glucoseOffset, slope: UserDefaults.standard.glucoseSlope)
            
            if let trendMeasurements = trendMeasurements {
                setBloodGlucoseHighOrLowNotificationIfNecessary(trendMeasurements: trendMeasurements)
            }
            
            if let historyMeasurements = historyMeasurements, sensorData.state == .ready {
                
                // fetch all records that are newer than the oldest history measurement of the new data
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let request = BloodGlucose.fetchRequest(from: Date(timeIntervalSinceNow: TimeInterval(-30600))) as NSFetchRequest<BloodGlucose> // 8.5 h = 30600 s
                do {
                    let fetchedBloodGlucoses = try persistentContainer?.viewContext.fetch(request)
                    
                    // Loop over all and check if new data exists and store the new data if not yet existent
                    historyMeasurements.forEach({measurement in
                        
                        os_log("HistoryMeasurement: %{public}@", log: BloodSugarTableViewController.bt_log, type: .default, measurement.description)
                        
                        var storeMeasurement = true
                        // Check if there is already a record stored for the same time
                        for bloodGlucose in fetchedBloodGlucoses! {
                            
                            // Found a value within time range that is already stored, so do not store the value just read from the sensor (since it is already stored)
                            // Time range criteria is fulfilled if dates of stored value and value just read from sensor are less than two minutes apart from each other (in either direction)
                            if let bloodGlucoseDate = bloodGlucose.date, abs(bloodGlucoseDate.timeIntervalSince(measurement.date)) < 120.0 {
                                
                                os_log("Fetched Glucose %{public}@", log: BloodSugarTableViewController.bt_log, type: .default, String(describing: "\(bloodGlucose.value) at \(String(describing: bloodGlucose.date))"))
                                os_log("Do not store: %{public}@", log: BloodSugarTableViewController.bt_log, type: .default, String(describing: "\(measurement.glucose) at \(String(describing: measurement.date))"))
                                storeMeasurement = false
                                break
                            }
                        }
                        ///* 2018-10-27: Skip storing history data in core data for test purposes
                        // Store if there isn't a measurement yet for this time and if it is a possible value (i.e. greater than zero and greater than offset)
                        if storeMeasurement && (UserDefaults.standard.glucoseOffset < measurement.glucose) && (0.0 < measurement.glucose) {
                            
                            fetchedBloodGlucoses?.forEach({ bloodGlucose in
                                os_log("Fetched Glucose %{public}@", log: BloodSugarTableViewController.bt_log, type: .default, String(describing: "\(bloodGlucose.value) at \(String(describing: bloodGlucose.date))"))
                            })
                            os_log("Store this one: %{public}@", log: BloodSugarTableViewController.bt_log, type: .default, measurement.description)
                            
                            let glucose = BloodGlucose(context: (persistentContainer?.viewContext)!)
                            glucose.bytes = measurement.byteString
                            glucose.value = measurement.glucose
                            glucose.date = measurement.date as NSDate
                            glucose.dateString = dateFormatter.string(from: measurement.date)
                            
                            // Prepare for nightscout
                            nightscoutEntries.append(NightscoutEntry(glucose: Int(measurement.glucose), timestamp: measurement.date, device: "LibreMonitor", glucoseType: .Sensor))
                        }
                        //*/
                    })
                    // send to nightscout
                    if UserDefaults.standard.uploadToNightscoutIsActivated {
                        uploader?.processFreestyleLibreHistoryEntries(nightscoutEntries: nightscoutEntries)
                        nightscoutEntries = []
                    }
                    try? persistentContainer?.viewContext.save()
                    
                } catch {
                    fatalError("Failed to fetch BloodGlucose: \(error)")
                }
            }
        }
        tableView.reloadData()
    }
    
    
    func miaoMiaoManagerReceivedMessage(_ messageIdentifier: UInt16, txFlags: UInt8, payloadData: Data) {
     }
    
    
    
    // MARK: - Helper functions
    
    // Timer to update diplayed time every five seconds
    // TODO: This way the whole section is reloaded every five seconds. Solve this by moving the displayed time into a table view row or dedicated view
    func resetTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(5), repeats: true, block: {timer in
            self.tableView.reloadSections(IndexSet(integer: Section.graphHeader.rawValue), with: .none)
        })
    }

    func colorForConnectionMiaoMiaoState() -> UIColor {
        switch (miaoMiaoManager.state) {
        case .Unassigned, .Disconnected, .DisconnectingDueToButtonPress:
            return UIColor.red
        case .Scanning, .Connecting, .Connected:
            return UIColor(red: CGFloat(0.9), green: CGFloat(0.9), blue: CGFloat(1), alpha: CGFloat(1))
        case .Notifying:
            return UIColor.green
        }
    }

    func colorForSensorState(sensorState: SensorState) -> UIColor {
        switch sensorState {
        case .ready:
            return UIColor.white
        case .starting:
            return UIColor.orange
        case .expired, .failure, .shutdown, .notYetStarted, .unknown:
            return UIColor.red
        }
    }
    
    func colorForSensorCRCs(_ bool: Bool) -> UIColor {
        if bool == false {
            return UIColor.red
        }
        return UIColor.white
    }
    
    
    func connectButtonTitleForMiaoMiaoState(_ state: MiaoMiaoManagerState) -> String {
        
        switch state {
        case .Unassigned, .Disconnected, .DisconnectingDueToButtonPress:
            return "connect"
        case .Connected, .Connecting, .Scanning, .Notifying:
            return "disconnect"
        }
    }
    
    // MARK: - Notifications and badge icon
    
    func setBloodGlucoseHighOrLowNotificationIfNecessary(trendMeasurements: [Measurement] ) {

        let currentGlucose = trendMeasurements[0].glucose
        let longDelta = currentGlucose - trendMeasurements[15].glucose
        let shortDelta = (currentGlucose - trendMeasurements[8].glucose) * 2.0 * 16.0/15.0
        let longPrediction = currentGlucose + longDelta
        let shortPrediction = currentGlucose + shortDelta
        
        // Show high blood glucose alert if conditions are reached
        if (longPrediction > 180.0) || (shortPrediction > 180.0) || (longDelta > 30.0 && shortDelta > 30.0) {
            
            let body = String(format: "%0.0f --> %0.0f (%0.0f), Delta: %0.0f (%0.0f)", arguments: [currentGlucose, longPrediction, shortPrediction, longDelta, shortDelta])
            NotificationManager.setBloodGlucoseHighOrLowNotification(title: "High Glucose", body: body)
            
        } else if (longPrediction > 0 && longPrediction < 60.0 ) || (shortPrediction > 0 && shortPrediction < 66.0 ) || (longDelta < -30.0 && shortDelta < -30.0) {
            
            let body = String(format: "%0.0f --> %0.0f (%0.0f), Delta: %0.0f (%0.0f)", arguments: [currentGlucose, longPrediction, shortPrediction, longDelta, shortDelta])
            NotificationManager.setBloodGlucoseHighOrLowNotification(title: "Low Glucose", body: body)
        }
        NotificationManager.applicationIconBadgeNumber(value: Int(round(longPrediction)))
        
//        // Show corresponding app icon
//        NotificationManager.setAlternativeAppIconForGlucoseDelta(longDelta)
    }
    
    // MARK: - LibreOOPWeb
    
    
    /// Gets glucose value from OOP web interface from @dabear.
    ///
    /// Gets glucose value from real Abbott algorithm for Freestyle Libre by sending data to a webserver that itself sends the data to an Android phone that calculates the glucose value from the fram data by using the LibreLink Android app (or apk).
    ///
    /// Since this is async: A closure will be called, when the value arrives and the glucose value will then be stored in a local variable of the view controller.
    ///
    /// - Parameter fram: 344 bytes of fram of the Freestyle Libre sensor
    func getOOPGlucose(fram: [UInt8]) {
        
        // OOP Webinterface
        oopCurrentValue = nil
        guard UserDefaults.standard.oopWebInterfaceIsActivated else {
            return
        }
        if let accessToken = UserDefaults.standard.oopWebInterfaceAPIToken,
            let site = UserDefaults.standard.oopWebInterfaceSite {
            let libreOOPClient = LibreOOPClient(accessToken: accessToken, site: site)
            libreOOPClient.uploadReading(reading: fram) { (response, success, errormessage) in
                guard success else {
                    NSLog("remote: upload reading failed! \(errormessage)")
                    return
                }
                if let response = response, let uuid = response.result?.uuid {
                    print("uuid received: " + uuid)
                    
                    // The completion handler will be called once the result is available, or when a timeout is received
                    // The timeout can be calculated as approx (intervalSeconds * maxTries) seconds
                    // In case of timeout, the success parameter will be false, errormessage will have contents
                    // and the response will be "N/A"
                    // In case of success, response will be containing the result of the Algorithm
                    libreOOPClient.getStatusIntervalled(uuid: uuid, { (success, errormessage, oopCurrentValue, newSstate) in
                        self.oopCurrentValue = oopCurrentValue
                        NSLog("GetStatusIntervalled returned with success?: \(success), error: \(errormessage), response: \(oopCurrentValue.debugDescription), newstate: \(newSstate)")
                    })
                }
            }
        }
    }
}






