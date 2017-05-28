//
//  BloodGlucoseEntryEditTableViewController.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 23.04.17.
//  Copyright © 2017 Uwe Petersen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class BloodGlucoseEntryEditTableViewController: UITableViewController {
    
    var bloodGlucose: BloodGlucose?
    
    var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter
    }()
    

    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var bloodGlucoseTextField: UITextField!

    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var sensorIDLabel: UILabel!
    @IBOutlet weak var byteLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bloodGlucoseNumber = (bloodGlucose?.value ?? 0) as NSNumber
        
        if let bloodGlucose = bloodGlucose,
            let date = bloodGlucose.date
        {
            datePicker.date = date as Date
            dateLabel.text = DateFormatter.localizedString(from: date as Date, dateStyle: .short, timeStyle: .short)
            
            typeTextField.text = "\(bloodGlucose.type)"
            byteLabel.text = bloodGlucose.bytes
            idLabel.text = "\(bloodGlucose.id)"
            sensorIDLabel.text = bloodGlucose.sensor?.uid
        }
    }
    
    // MARK: - Date Picker
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        dateLabel.text = DateFormatter.localizedString(from: sender.date, dateStyle: .short, timeStyle: .short)
        bloodGlucose?.date = datePicker.date as NSDate
    }
    
    
    
    // MARK: - Blood Glucose Text Field

    @IBAction func bloodGlucoseTextFieldEditingChanged(_ sender: UITextField) {
        if let bloodGlucoseNumber = bloodGlucoseNumber {
            bloodGlucoseTextField.text = numberFormatter.string(from: bloodGlucoseNumber)
            bloodGlucose?.value = bloodGlucoseNumber.doubleValue
        } else {
            bloodGlucoseTextField.text = nil
            bloodGlucose?.value = 0
        }
    }
    
    
    var bloodGlucoseNumber: NSNumber? {
        get {
            return numberFormatter.number(from: bloodGlucoseTextField.text ?? "")
        }
        set {
            if let value = newValue {
                bloodGlucoseTextField.text = numberFormatter.string(from: value)
            } else {
                bloodGlucoseTextField.text = nil
            }
        }
    }
    
    // MARK: - Type Text Field
    
    @IBAction func typeTextFieldEditingChanged(_ sender: UITextField) {
    }


    // MARK: - Navigation
    
    @IBAction func undoButtonPressed(_ sender: UIBarButtonItem) {
        bloodGlucose?.managedObjectContext?.undoManager?.endUndoGrouping()
        bloodGlucose?.managedObjectContext?.undoManager?.undo()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        bloodGlucose?.managedObjectContext?.undoManager?.endUndoGrouping()
        bloodGlucose?.managedObjectContext?.undoManager?.removeAllActions()
        try? bloodGlucose?.managedObjectContext?.save()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
