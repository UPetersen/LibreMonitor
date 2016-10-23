//
//  Reader+CoreDataProperties.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 09.10.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation
import CoreData


extension Reader {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reader> {
        return NSFetchRequest<Reader>(entityName: "Reader");
    }

    @NSManaged public var batteryVoltage: Double
    @NSManaged public var temperature: Double
    @NSManaged public var uid: String?

}
