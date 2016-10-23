//
//  BloodGlucose+CoreDataProperties.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 09.10.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation
import CoreData

extension BloodGlucose {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BloodGlucose> {
        return NSFetchRequest<BloodGlucose>(entityName: "BloodGlucose");
    }

    @NSManaged public var bytes: String?
    @NSManaged public var dateString: String?
    @NSManaged public var id: Int32
    @NSManaged public var type: Int16
    @NSManaged public var value: Double
    @NSManaged public var date: NSDate?
    @NSManaged public var sensor: Sensor?

}
