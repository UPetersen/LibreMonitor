//
//  GlucoseCDTVC.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 19.04.17.
//  Copyright © 2017 Uwe Petersen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class GlucoseCDTVC: FetchedResultsTableViewController {
    
    var persistentContainer: NSPersistentContainer?
    var fetchedResultsController: NSFetchedResultsController<BloodGlucose>?
    var dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd    HH:mm:ss"
        dateFormatter.locale = NSLocale.current
        updateUI()
        self.navigationItem.rightBarButtonItems?.append(editButtonItem)
    }
    
     func updateUI() {
        
        if let context = persistentContainer?.viewContext {
            let request: NSFetchRequest<BloodGlucose> = BloodGlucose.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            request.predicate = nil // all
            fetchedResultsController = NSFetchedResultsController<BloodGlucose>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
    
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "glucoseCell", for: indexPath)
        if let bloodGlucose = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = bloodGlucose.value.description
            if let date = bloodGlucose.date {
                cell.detailTextLabel?.text = dateFormatter.string(from: date as Date)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let bloodGlucose = fetchedResultsController?.object(at: indexPath) {
                persistentContainer?.viewContext.delete(bloodGlucose)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    // MARK: - TableView Delegate


    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            
            switch identifier {
            case "editBloodGlucose":
                if  let navController = segue.destination as? UINavigationController,
                    let vc = navController.topViewController as? BloodGlucoseEntryEditTableViewController,
                    let cell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: cell),
                    let bloodGlucose = fetchedResultsController?.object(at: indexPath)
                {
                    persistentContainer?.viewContext.undoManager = UndoManager()
                    persistentContainer?.viewContext.undoManager?.beginUndoGrouping()
                    vc.bloodGlucose = bloodGlucose
                }
            case "addBloodGlucose":
                if  let navController = segue.destination as? UINavigationController,
                    let vc = navController.topViewController as? BloodGlucoseEntryEditTableViewController
                {
                    persistentContainer?.viewContext.undoManager = UndoManager()
                    persistentContainer?.viewContext.undoManager?.beginUndoGrouping()

                    let bloodGlucose = BloodGlucose(context: (persistentContainer?.viewContext)!)
                    bloodGlucose.date = Date() as NSDate
                    
                    vc.bloodGlucose = bloodGlucose
                }
            default: break
            }
        }
    }
}
