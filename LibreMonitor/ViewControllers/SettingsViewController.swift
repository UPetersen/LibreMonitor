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
    var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    @IBOutlet weak var glucoseOffsetTextField: UITextField!
    @IBOutlet weak var glucoseSlopeTextField: UITextField!
    
    @IBOutlet weak var uplodToNightscoutSwitch: UISwitch!
    @IBOutlet weak var nightscoutSiteTextField: UITextField!
    @IBOutlet weak var nightScoutAPISecretTextField: UITextField!
    @IBOutlet weak var verifyAccountButton: UIButton!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
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
        temperatureAlgorithmTextView.text = "MiaoMiaoManager state is \(miaoMiaoManager.state)"
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
        spinner.startAnimating()
        
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
                //                    UIView.animate(withDuration: 0.25, animations: {
                //                        self.verifyAccountButton.title = "verifyng"
                //                    })
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
        UserDefaults.standard.set(sender.isOn, forKey: "useOOPWebInterfaceIsActivated")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - temperature algo
    @IBOutlet weak var useTemperatureAlgorithmSwitch: UISwitch!
    @IBOutlet weak var temperatureAlgorithmTextView: UITextView!
    
    @IBAction func useTemperatureAlgorithmSwitchChanged(_ sender: UISwitch) {
        self.view.endEditing(true) // resign keyboard
        temperatureAlgorithmTextView.text = "Switch is \(useTemperatureAlgorithmSwitch.isOn)"
    }
    @IBAction func startCalibrationPressed(_ sender: UIButton) {
        temperatureAlgorithmTextView.text = " Pressed that text field and request new data"
        miaoMiaoManager.requestData()
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
        
        spinner.stopAnimating() // Verify account always ends with a alert displayed. Thus stop spinner here.
        
        present(alertController, animated: true, completion: nil)
    }
    
    
}

