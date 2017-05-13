//
//  NotificationManager.swift
//  Pods
//
//  Created by Uwe Petersen on 13.05.17.
//
//

import Foundation
import UserNotifications
import UIKit

@available(iOS 10.0, *)
struct NotificationManager {
    
    enum Category: String {
        case BluetoothDisconnected
        case someInfiniteLoop
        case batteryLow
        case bloodSugarLow
        case bloodSugarHigh
        case debug
    }
    
    static func authorize(delegate: UNUserNotificationCenterDelegate) {
    
        let center = UNUserNotificationCenter.current()
        center.delegate = delegate
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                //  application.registerForRemoteNotifications()
            }
        }
    }
    
    // MARK: - Local Notifications
    
    
    
    // MARK: - Local Notifications used for debugging
    
    static func scheduleDebugNotification(message: String, timeInterval: TimeInterval) {
        
        let content = UNMutableNotificationContent()
        content.title = "DebugTimer"
        content.subtitle = "Something took too long (\(timeInterval) s):"
        content.body = message
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: Category.debug.rawValue,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    
    static func removePendingDebugNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Category.debug.rawValue])
    }
    
}

