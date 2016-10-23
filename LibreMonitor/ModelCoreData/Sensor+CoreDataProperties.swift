//
//  Sensor+CoreDataProperties.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 09.10.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation
import CoreData

extension Sensor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sensor> {
        return NSFetchRequest<Sensor>(entityName: "Sensor");
    }

    @NSManaged public var startDate: NSDate?
    @NSManaged public var uid: String?
    @NSManaged public var lastScanDate: NSDate?
    @NSManaged public var minutesSinceStart: Int32
    @NSManaged public var bloodGlucose: NSSet?

}

// MARK: Generated accessors for bloodGlucose
extension Sensor {

    @objc(addBloodGlucoseObject:)
    @NSManaged public func addToBloodGlucose(_ value: BloodGlucose)

    @objc(removeBloodGlucoseObject:)
    @NSManaged public func removeFromBloodGlucose(_ value: BloodGlucose)

    @objc(addBloodGlucose:)
    @NSManaged public func addToBloodGlucose(_ values: NSSet)

    @objc(removeBloodGlucose:)
    @NSManaged public func removeFromBloodGlucose(_ values: NSSet)

}
