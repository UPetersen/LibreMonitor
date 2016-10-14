//
//  HeaderData+CoreDataProperties.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 14.10.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import Foundation
import CoreData


extension HeaderData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HeaderData> {
        return NSFetchRequest<HeaderData>(entityName: "HeaderData");
    }

    @NSManaged public var bytes: String?
    @NSManaged public var date: NSDate?

}
