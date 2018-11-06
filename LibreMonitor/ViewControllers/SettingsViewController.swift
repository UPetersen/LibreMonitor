//
//  SettingsViewController.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 21.08.17.
//  Copyright © 2017 Uwe Petersen. All rights reserved.
//

import Foundation
import UIKit

final class SettingsViewController: UITableViewController, UITextFieldDelegate {
    
    var miaoMiaoManager: MiaoMiaoManager!
    var calibrationManager = CalibrationManager()
    
    var additionalSlope = 0.0
    var additionalOffset = 0.0

    var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        return dateFormatter
    }()
    
    @IBOutlet weak var glucoseOffsetTextField: UITextField!
    @IBOutlet weak var glucoseSlopeTextField: UITextField!
    
    @IBOutlet weak var uplodToNightscoutSwitch: UISwitch!
    @IBOutlet weak var nightscoutSiteTextField: UITextField!
    @IBOutlet weak var nightScoutAPISecretTextField: UITextField!
    @IBOutlet weak var verifyAccountButton: UIButton!
    @IBOutlet var veryfiyAccountActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var useOOPWebInterfaceSwitch: UISwitch!
    @IBOutlet weak var oopWebInterfaceSiteTextField: UITextField!
    @IBOutlet weak var oopWebInterfaceAPITokenTextField: UITextField!
    
    
    @IBOutlet weak var startCalibrationButton: UIButton!
    
    // MARK: - functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        glucoseOffsetTextField.delegate = self
        glucoseSlopeTextField.delegate = self
        nightscoutSiteTextField.delegate = self
        nightScoutAPISecretTextField.delegate = self
        
        oopWebInterfaceAPITokenTextField.delegate = self
        oopWebInterfaceSiteTextField.delegate = self
        
        temperatureParametersAdditionalSlope.delegate = self
        temperatureParametersAdditionalOffset.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Section with offset and slope
        let bloodGlucoseOffset = UserDefaults.standard.double(forKey: "bloodGlucoseOffset")
        let bloodGlucoseSlope = UserDefaults.standard.double(forKey: "bloodGlucoseSlope")
        
        glucoseOffsetTextField.text = numberFormatter.string(from: NSNumber(value: bloodGlucoseOffset))
        glucoseSlopeTextField.text = numberFormatter.string(from: NSNumber(value: bloodGlucoseSlope))
        
        // Nightscout Section
        uplodToNightscoutSwitch.isOn = UserDefaults.standard.bool(forKey: "uploadToNightscoutIsActivated") // returns false if not yet initialized, which is what we want in that case
        nightscoutSiteTextField.text = UserDefaults.standard.string(forKey: "nightscoutSite")
        nightScoutAPISecretTextField.text = UserDefaults.standard.string(forKey: "nightscoutAPISecret")
        
        // OOP web interface
        useOOPWebInterfaceSwitch.isOn = UserDefaults.standard.bool(forKey: "oopWebInterfaceIsActivated") // returns false if not yet initialized, which is what we want in that case
        oopWebInterfaceSiteTextField.text = UserDefaults.standard.string(forKey: "oopWebInterfaceSite")
        oopWebInterfaceAPITokenTextField.text = UserDefaults.standard.string(forKey: "oopWebInterfaceAPIToken")
        
        // Temperature Algorithm
        configureTemperatureAlgorithmParameterCells()
    }
    
    func configureTemperatureAlgorithmParameterCells() {
        if let derivedParameters = calibrationManager.calibrationParameters {
            temperatureParametersDate.text = dateFormatter.string(from: derivedParameters.date)
            temperatureParametersIsValidForFooterCRCs.text = String(format: "%0d", derivedParameters.isValidForFooterWithReverseCRCs)
            temperatureParametersSlopeSlope.text = String(format: "%5.3e", derivedParameters.slope_slope)
            temperatureParametersOffsetSlope.text = String(format: "%5.3e", derivedParameters.offset_slope)
            temperatureParametersSlopeOffset.text = String(format: "%5.3e", derivedParameters.slope_offset)
            temperatureParametersOffsetOffset.text = String(format: "%5.3e", derivedParameters.offset_offset)
            temperatureParametersAdditionalSlope.text = String(format: "%5.3f", derivedParameters.additionalSlope)
            temperatureParametersAdditionalOffset.text = String(format: "%3.0f", derivedParameters.additionalOffset)
            additionalSlope = derivedParameters.additionalSlope
            additionalOffset = derivedParameters.additionalOffset
        }
    }

    @IBAction func tapGestureRecognized(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true) // resign keyoard
    }
    
    
    // MARK: - Nightscout Section
    
    @IBAction func uploadToNightscoutSwitchChanged(_ sender: UISwitch) {
        self.view.endEditing(true) // resign keyboard
        UserDefaults.standard.set(sender.isOn, forKey: "uploadToNightscoutIsActivated")
    }
    
    @IBAction func verifyAccountButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true) //resign keyboard
        veryfiyAccountActivityIndicator.startAnimating()
        
        // This is kind of awkward: textfield editing does not end when pressing verify button, thus get the textField values here, too.
        UserDefaults.standard.set(nightscoutSiteTextField.text, forKey: "nightscoutSite")
        UserDefaults.standard.set(nightScoutAPISecretTextField.text, forKey: "nightscoutAPISecret")
        
        guard let site = UserDefaults.standard.string(forKey: "nightscoutSite"),
            let siteURL = URL.init(string: site) else {
                self.presentVerificationResultAlertController(title: "Site URL", message: "Your site URL is not a valid URL. Please enter a valid url.")
                return
        }
        guard let apiSecret = UserDefaults.standard.string(forKey: "nightscoutAPISecret") else {
                self.presentVerificationResultAlertController(title: "API secret", message: "Please enter the password for your nightscout site.")
                return
        }
        let uploader = NightscoutUploader(siteURL: siteURL, APISecret: apiSecret)
        
        uploader.verify { [unowned self] (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.presentVerificationResultAlertController(title: "Verification successful", message: "Your nightscout account was veryfied successfully.")
                } else {
                    if let error = error {
                        self.presentVerificationResultAlertController(title: "Verification error. ", message: "Your account could not be verified. \nError message:\n \"\(error.localizedDescription)\". \nCheck site URL, API secret and internet connection.")
                    }
                }
            }
        }
    }
    
    // MARK: - OOP web interface
    
    @IBAction func useOOPWebInterfaceSwitchChanged(_ sender: UISwitch) {
        self.view.endEditing(true) // resign keyboard
        UserDefaults.standard.set(sender.isOn, forKey: "oopWebInterfaceIsActivated")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - temperature algo
    @IBOutlet weak var useTemperatureAlgorithmSwitch: UISwitch!
    @IBOutlet weak var temperatureParametersDate: UITextField!
    @IBOutlet weak var temperatureParametersIsValidForFooterCRCs: UITextField!
    @IBOutlet weak var temperatureParametersSlopeSlope: UITextField!
    @IBOutlet weak var temperatureParametersOffsetSlope: UITextField!
    @IBOutlet weak var temperatureParametersSlopeOffset: UITextField!
    @IBOutlet weak var temperatureParametersOffsetOffset: UITextField!
    @IBOutlet weak var temperatureParametersAdditionalSlope: UITextField!
    @IBOutlet weak var temperatureParametersAdditionalOffset: UITextField!
    
    @IBOutlet weak var temperatureAlgorithmTextView: UITextView!
    
    @IBAction func useTemperatureAlgorithmSwitchChanged(_ sender: UISwitch) {
        self.view.endEditing(true) // resign keyboard
        temperatureAlgorithmTextView.text = "Switch is \(useTemperatureAlgorithmSwitch.isOn)"
    }
    @IBOutlet weak var getParametersActivityIndicator: UIActivityIndicatorView!
    @IBAction func startCalibrationPressed(_ sender: UIButton) {
        getParametersActivityIndicator.startAnimating()
        
        guard let accessToken = UserDefaults.standard.string(forKey: "oopWebInterfaceAPIToken"),
            let site = UserDefaults.standard.string(forKey: "oopWebInterfaceSite"),
            let sensorData = miaoMiaoManager.sensorData else {
                self.presentGetParameterResultAlertController(title: "Get Parameters Failed", message: "Cannot request new data, because site url, access token or sensor datais not valid")
                return
        }

        let libreOOPClient = LibreOOPClient(accessToken: accessToken, site: site)
        libreOOPClient.uploadCalibration(reading: sensorData.bytes, {calibrationResult, success, errormessage in
            guard success, let calibrationResult = calibrationResult else {
                DispatchQueue.main.async {
                    self.presentGetParameterResultAlertController(title: "Get Parameters Failed", message: "Reason: \(errormessage)")
                    self.getParametersActivityIndicator.stopAnimating()
                }
                NSLog("remote: upload calibration failed! \(errormessage)")
                return
            }
            NSLog("uuid received: " + calibrationResult.uuid)
            libreOOPClient.getCalibrationStatusIntervalled(uuid: calibrationResult.uuid, {success, errormessage, parameters in
                // check for data integrity
                guard success,
                    let parameters = parameters,
                    sensorData.footerCrc == UInt16(parameters.isValidForFooterWithReverseCRCs).byteSwapped else {
                        DispatchQueue.main.async {
                            self.presentGetParameterResultAlertController(title: "Get Parameters Failed", message: "Reason: \(errormessage)")
                            self.getParametersActivityIndicator.stopAnimating()
                        }
                        return
                }
                DispatchQueue.main.async {
                    self.presentReceivedNewParametersAlertController(newParameters: parameters)
                    self.getParametersActivityIndicator.stopAnimating()
                }
                NSLog("GetStatusIntervalled returned with success?: \(success), error: \(errormessage), response: \(parameters.description)")
            })
        })
    }

    // MARK: - textfield handling
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case nightscoutSiteTextField:
            UserDefaults.standard.set(textField.text, forKey: "nightscoutSite")
        case nightScoutAPISecretTextField:
            UserDefaults.standard.set(textField.text, forKey: "nightscoutAPISecret")
        case glucoseOffsetTextField:
            handleNumericTextFieldInput(textField)
        case glucoseSlopeTextField:
            handleNumericTextFieldInput(textField)
        case oopWebInterfaceSiteTextField:
            UserDefaults.standard.set(textField.text, forKey: "oopWebInterfaceSite")
        case oopWebInterfaceAPITokenTextField:
            UserDefaults.standard.set(textField.text, forKey: "oopWebInterfaceAPIToken")
        case temperatureParametersAdditionalSlope:
            handleNumericTextFieldInput(textField)
        case temperatureParametersAdditionalOffset:
            handleNumericTextFieldInput(textField)
        default:
            fatalError("Fatal Error in \(#file): textField not handled in switch case")
            break
        }
        return true
    }

    func handleNumericTextFieldInput(_ textField: UITextField) {
        guard let aNumber = numberFormatter.number(from: textField.text!) else {
            displayAlertForTextField(textField)
            return
        }
        
        switch textField {
        case glucoseOffsetTextField:
            let bloodGlucoseOffset = Double(truncating: aNumber)
            UserDefaults.standard.set(bloodGlucoseOffset, forKey: "bloodGlucoseOffset")
        case glucoseSlopeTextField:
            let bloodGlucoseSlope = Double(truncating: aNumber)
            UserDefaults.standard.set(bloodGlucoseSlope, forKey: "bloodGlucoseSlope")
        case temperatureParametersAdditionalSlope:
            additionalSlope = Double(truncating: aNumber)
            if let derivedParameters = calibrationManager.calibrationParameters {
                CalibrationManager().calibrationParameters = DerivedAlgorithmParameterSet(
                    slope_slope: derivedParameters.slope_slope,
                    offset_slope: derivedParameters.offset_slope,
                    slope_offset: derivedParameters.slope_offset,
                    offset_offset: derivedParameters.offset_offset,
                    additionalSlope: self.additionalSlope,
                    additionalOffset: derivedParameters.additionalOffset,
                    isValidForFooterWithReverseCRCs: derivedParameters.isValidForFooterWithReverseCRCs
                )
            }
        case temperatureParametersAdditionalOffset:
            additionalOffset = Double(truncating: aNumber)
            if let derivedParameters = calibrationManager.calibrationParameters {
                CalibrationManager().calibrationParameters = DerivedAlgorithmParameterSet(
                    slope_slope: derivedParameters.slope_slope,
                    offset_slope: derivedParameters.offset_slope,
                    slope_offset: derivedParameters.slope_offset,
                    offset_offset: derivedParameters.offset_offset,
                    additionalSlope: derivedParameters.additionalSlope,
                    additionalOffset: self.additionalOffset,
                    isValidForFooterWithReverseCRCs: derivedParameters.isValidForFooterWithReverseCRCs
                )
            }
        default:
            fatalError("Fatal Error in \(#file): textField not handled in switch case")
            break
        }
        
        // update table view
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateBloodSugarTableViewController"), object: self)
    }

    // MARK: - Convenience methods
    
    func displayAlertForTextField(_ textField: UITextField) {
        let message = String(format: "\"\(textField.text!)\" is not a valid number.", [])
        let alertController = UIAlertController(title: "Invalid input", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentVerificationResultAlertController(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        veryfiyAccountActivityIndicator.stopAnimating() // Verify account always ends with a alert displayed. Thus stop spinner here.
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentGetParameterResultAlertController(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.getParametersActivityIndicator.stopAnimating()
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentReceivedNewParametersAlertController(newParameters: DerivedAlgorithmParameters) {
        var message = "Old Parameterset:\n"
        message.append(self.calibrationManager.calibrationParameters?.description ?? "-")
        message.append("\n\nNew Parameterset:\n")
        message.append(newParameters.description)
        
        let alertController = UIAlertController(title: "Parameter set recieved", message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let saveNewParametersAction = UIAlertAction(title: "Save", style: .default, handler: {uiAlertAction in
            print("I will save this stuff")
            CalibrationManager().calibrationParameters = DerivedAlgorithmParameterSet(
                slope_slope: newParameters.slope_slope,
                offset_slope: newParameters.offset_slope,
                slope_offset: newParameters.slope_offset,
                offset_offset: newParameters.offset_offset,
                additionalSlope: self.additionalSlope,
                additionalOffset: self.additionalOffset,
                isValidForFooterWithReverseCRCs: newParameters.isValidForFooterWithReverseCRCs
            )

        })
        alertController.addAction(cancelAction)
        alertController.addAction(saveNewParametersAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

