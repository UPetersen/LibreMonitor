//
//  BloodGlucose+CoreDataProperties.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 14.10.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation
import CoreData 

extension BloodGlucose {

    @nonobjc public class func fetchRequest(from date: Date? = nil) -> NSFetchRequest<BloodGlucose> {
        let request = NSFetchRequest<BloodGlucose>(entityName: "BloodGlucose")
        if let date = date {
            request.predicate = NSPredicate(format: "date > %@", date as NSDate)
        }
        return request
    }

    @NSManaged public var bytes: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var dateString: String?
    @NSManaged public var id: Int32
    @NSManaged public var type: Int16
    @NSManaged public var value: Double
    @NSManaged public var sensor: Sensor?

}
