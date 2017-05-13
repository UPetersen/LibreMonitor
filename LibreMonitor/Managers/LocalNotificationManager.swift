////
////  LocalNotificationManager.swift
////  LibreMonitor
////
////  Created by Uwe Petersen on 13.05.17.
////  Copyright © 2017 Uwe Petersen. All rights reserved.
////
//
//import Foundation
//import UIKit
//import UserNotifications
//
//class LocalNotificationManager {
//    
//    private static let debugNotificationIdentifier = "debugNotificationIdentifier"
//    
//    class func scheduleDebugNotification(message: String, timeInterval: TimeInterval) {
//        
//        let content = UNMutableNotificationContent()
//        content.title = "DebugTimer"
//        content.subtitle = "Something took too long (\(timeInterval) s):"
//        content.body = message
//        content.sound = UNNotificationSound.default()
//        content.categoryIdentifier = "DEBUG_NOTIFICATION"
//        content.userInfo = ["UUID": "999"]
//        
//        let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
//        let request = UNNotificationRequest(identifier: debugNotificationIdentifier, content: content, trigger: timeTrigger)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//    }
//    
//    class func removePendingDebugNotification() {
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [LocalNotificationManager.debugNotificationIdentifier])
//    }
//    
//}
