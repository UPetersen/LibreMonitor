//
//  AdjustmentsTableViewController.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 27.05.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation
import UIKit

class AdjustmentsTableViewController: UITableViewController, UITextFieldDelegate {
    

    let numberFormatter = NumberFormatter()
    
    @IBOutlet weak var offsetTextField: UITextField!
    @IBOutlet weak var slopeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.numberStyle = .decimal
        offsetTextField.delegate = self // for handling return key
        slopeTextField.delegate = self
        
        let bloodGlucoseOffset = UserDefaults.standard.double(forKey: "bloodGlucoseOffset")
        let bloodGlucoseSlope = UserDefaults.standard.double(forKey: "bloodGlucoseSlope")
        
        offsetTextField.text = numberFormatter.string(from: NSNumber(value: bloodGlucoseOffset))
        slopeTextField.text = numberFormatter.string(from: NSNumber(value: bloodGlucoseSlope))
                
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(AdjustmentsTableViewController.didTapSaveButton))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(AdjustmentsTableViewController.didTapUndoButton))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkInputForTextField(textField)
        return true
    }
    
    
    func didTapSaveButton() {
        checkInputForTextField(offsetTextField)
        checkInputForTextField(slopeTextField)
    }
    
    func checkInputForTextField(_ textField: UITextField) {
        guard let aNumber = numberFormatter.number(from: textField.text!) else {
            displayAlertForTextField(textField)
            return
        }
        
        switch textField {
        case offsetTextField:
            let bloodGlucoseOffset = Double(aNumber)
            UserDefaults.standard.set(bloodGlucoseOffset, forKey: "bloodGlucoseOffset")
        case slopeTextField:
            let bloodGlucoseSlope = Double(aNumber)
            UserDefaults.standard.set(bloodGlucoseSlope, forKey: "bloodGlucoseSlope")
        default:
            fatalError("Fatal Error in \(#file): textField not handled in switch case")
            break
        }
        
        // update table view
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateBloodSugarTableViewController"), object: self)
        
        resignFirstResponder()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func didTapUndoButton() {
        resignFirstResponder()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func displayAlertForTextField(_ textField: UITextField) {
        let message = String(format: "\"\(textField.text!)\" ist kein gültiger Wert, bitte korrigieren.", [])
        let alertController = UIAlertController(title: "Ungültige Eingabe", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
