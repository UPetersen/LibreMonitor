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
        let glucoseSlope = UserDefaults.standard.glucoseSlope
        let glucoseOffset = UserDefaults.standard.glucoseOffset
        glucoseSlopeTextField.text = numberFormatter.string(from: NSNumber(value: glucoseSlope))
        glucoseOffsetTextField.text = numberFormatter.string(from: NSNumber(value: glucoseOffset))
        
        // Nightscout Section
        uplodToNightscoutSwitch.isOn = UserDefaults.standard.uploadToNightscoutIsActivated
        nightscoutSiteTextField.text = UserDefaults.standard.nightscoutSite
        nightScoutAPISecretTextField.text = UserDefaults.standard.nightscoutAPISecret
        
        // OOP web interface
        useOOPWebInterfaceSwitch.isOn = UserDefaults.standard.oopWebInterfaceIsActivated // returns false if not yet initialized, which is what we want in that case
        oopWebInterfaceSiteTextField.text = UserDefaults.standard.oopWebInterfaceSite
        oopWebInterfaceAPITokenTextField.text = UserDefaults.standard.oopWebInterfaceAPIToken
        
        // Temperature Algorithm
        useTemperatureAlgorithmSwitch.isOn = UserDefaults.standard.useTemperatureAlgorithm
        configureTemperatureAlgorithmParameterCells()
    }
    
    func configureTemperatureAlgorithmParameterCells() {
        if let derivedParameters = UserDefaults.standard.temperatureParameters {
            temperatureParametersDate.text = dateFormatter.string(from: derivedParameters.date)
            temperatureParametersSlopeSlope.text = String(format: "%5.3g", derivedParameters.slope_slope)
            temperatureParametersOffsetSlope.text = String(format: "%5.3g", derivedParameters.offset_slope)
            temperatureParametersSlopeOffset.text = String(format: "%5.3g", derivedParameters.slope_offset)
            temperatureParametersOffsetOffset.text = String(format: "%5.3g", derivedParameters.offset_offset)
            temperatureParametersAdditionalSlope.text = String(format: "%5.3g", derivedParameters.additionalSlope)
            temperatureParametersAdditionalOffset.text = String(format: "%5.3g", derivedParameters.additionalOffset)
            temperatureParametersIsValidForFooterCRCs.text = String(format: "%0d", derivedParameters.isValidForFooterWithReverseCRCs)
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
        UserDefaults.standard.uploadToNightscoutIsActivated = sender.isOn
    }
    
    @IBAction func verifyAccountButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true) //resign keyboard
        veryfiyAccountActivityIndicator.startAnimating()
        
        // This is kind of awkward: textfield editing does not end when pressing verify button, thus get the textField values here, too.
        UserDefaults.standard.nightscoutSite = nightscoutSiteTextField.text
        UserDefaults.standard.nightscoutAPISecret = nightScoutAPISecretTextField.text
        guard let site = UserDefaults.standard.nightscoutSite,
            let siteURL = URL.init(string: site) else {
                self.presentVerificationResultAlertController(title: "Site URL", message: "Your site URL is not a valid URL. Please enter a valid url.")
                return
        }
        guard let apiSecret = UserDefaults.standard.nightscoutAPISecret else {
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
        UserDefaults.standard.oopWebInterfaceIsActivated = sender.isOn
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
    
    @IBAction func useTemperatureAlgorithmSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.useTemperatureAlgorithm = sender.isOn
        self.view.endEditing(true) // resign keyboard
    }
    @IBOutlet weak var getParametersActivityIndicator: UIActivityIndicatorView!
    @IBAction func startCalibrationPressed(_ sender: UIButton) {
        getParametersActivityIndicator.startAnimating()
        
        guard let accessToken = UserDefaults.standard.oopWebInterfaceAPIToken,
            let site = UserDefaults.standard.oopWebInterfaceSite,
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
                guard success else {
                    DispatchQueue.main.async {
                        self.presentGetParameterResultAlertController(title: "Get Parameters Failed", message: "Reason: \(errormessage)")
                        self.getParametersActivityIndicator.stopAnimating()
                    }
                    return
                }
                guard let parameters = parameters,
                    sensorData.footerCrc == UInt16(parameters.isValidForFooterWithReverseCRCs).byteSwapped else {
                        DispatchQueue.main.async {
                            self.presentGetParameterResultAlertController(title: "Get Parameters Failed", message: "Wrong crc or no parameters returned.")
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
            UserDefaults.standard.nightscoutSite = textField.text
        case nightScoutAPISecretTextField:
            UserDefaults.standard.nightscoutAPISecret = textField.text
        case glucoseOffsetTextField:
            handleNumericTextFieldInput(textField)
        case glucoseSlopeTextField:
            handleNumericTextFieldInput(textField)
        case oopWebInterfaceSiteTextField:
            UserDefaults.standard.oopWebInterfaceSite = textField.text
        case oopWebInterfaceAPITokenTextField:
            UserDefaults.standard.oopWebInterfaceAPIToken = textField.text
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
            UserDefaults.standard.glucoseOffset = Double(truncating: aNumber)
        case glucoseSlopeTextField:
            UserDefaults.standard.glucoseSlope = Double(truncating: aNumber)
        case temperatureParametersAdditionalSlope:
            additionalSlope = Double(truncating: aNumber)
            if let temperatureParameters = UserDefaults.standard.temperatureParameters {
                UserDefaults.standard.temperatureParameters = TemperatureAlgorithmParameters(
                    slope_slope: temperatureParameters.slope_slope,
                    offset_slope: temperatureParameters.offset_slope,
                    slope_offset: temperatureParameters.slope_offset,
                    offset_offset: temperatureParameters.offset_offset,
                    additionalSlope: self.additionalSlope, // this one is the new value to store
                    additionalOffset: temperatureParameters.additionalOffset,
                    isValidForFooterWithReverseCRCs: temperatureParameters.isValidForFooterWithReverseCRCs
                )
            }
        case temperatureParametersAdditionalOffset:
            additionalOffset = Double(truncating: aNumber)
            if let temperatureParameters = UserDefaults.standard.temperatureParameters {
                UserDefaults.standard.temperatureParameters = TemperatureAlgorithmParameters(
                    slope_slope: temperatureParameters.slope_slope,
                    offset_slope: temperatureParameters.offset_slope,
                    slope_offset: temperatureParameters.slope_offset,
                    offset_offset: temperatureParameters.offset_offset,
                    additionalSlope: temperatureParameters.additionalSlope,
                    additionalOffset: self.additionalOffset, // this one is the new value to store
                    isValidForFooterWithReverseCRCs: temperatureParameters.isValidForFooterWithReverseCRCs
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
        var message = "\nOld Parameterset from \(self.temperatureParametersDate?.text ?? ""):\n"
        message.append("Slope_slope: \(self.temperatureParametersSlopeSlope.text ?? "")\n")
        message.append("Offset_slope: \(self.temperatureParametersOffsetSlope.text ?? "")\n")
        message.append("Slope_offset: \(self.temperatureParametersSlopeOffset.text ?? "")\n")
        message.append("Offset_offset: \(self.temperatureParametersOffsetOffset.text ?? "")\n")
        message.append("CRC: \(self.temperatureParametersIsValidForFooterCRCs.text ?? "")\n")

        message.append("\nNew Parameterset:\n")
        message.append(String(format: "Slope_slope: %5.3g\n", arguments: [newParameters.slope_slope]))
        message.append(String(format: "Offset_slope: %5.3g\n", arguments: [newParameters.offset_slope]))
        message.append(String(format: "Slope_offset: %5.3g\n", arguments: [newParameters.slope_offset]))
        message.append(String(format: "Offset_offset: %5.3g\n", arguments: [newParameters.offset_offset]))
        message.append(String(format: "CRC: %d\n", arguments: [newParameters.isValidForFooterWithReverseCRCs]))
        
        message.append("\nExamplary slope and offset for various temperatures:›\n\n")
        message.append(String(format: "slope(5500) = %5.3g mg/(dl * raw)\n", arguments: [newParameters.slope_slope * 5500 + newParameters.offset_slope]))
        message.append(String(format: "offset(5500) = %5.3g mg/dl\n\n", arguments: [newParameters.slope_offset * 5500 + newParameters.offset_offset]))
        message.append(String(format: "slope(6000) = %5.3g mg/(dl * raw)\n", arguments: [newParameters.slope_slope * 6000 + newParameters.offset_slope]))
        message.append(String(format: "offset(6500) = %5.3g mg/dl\n\n", arguments: [newParameters.slope_offset * 6000 + newParameters.offset_offset]))
        message.append(String(format: "slope(6500) = %5.3g mg/(dl * raw)\n", arguments: [newParameters.slope_slope * 6500 + newParameters.offset_slope]))
        message.append(String(format: "offset(6000) = %5.3g mg/dl\n\n", arguments: [newParameters.slope_offset * 6500 + newParameters.offset_offset]))
        message.append(String(format: "slope(7000) = %5.3g mg/(dl * raw)\n", arguments: [newParameters.slope_slope * 7000 + newParameters.offset_slope]))
        message.append(String(format: "offset(7000) = %5.3g mg/dl\n\n", arguments: [newParameters.slope_offset * 7000 + newParameters.offset_offset]))
        message.append(String(format: "slope(7500) = %5.3g mg/(dl * raw)\n", arguments: [newParameters.slope_slope * 7500 + newParameters.offset_slope]))
        message.append(String(format: "offset(7500) = %5.3g mg/dl\n", arguments: [newParameters.slope_offset * 7500 + newParameters.offset_offset]))

        let alertController = UIAlertController(title: "Parameter set received", message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let saveNewParametersAction = UIAlertAction(title: "Save", style: .default, handler: {uiAlertAction in
            print("I will save this stuff")
            UserDefaults.standard.temperatureParameters = TemperatureAlgorithmParameters(
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

