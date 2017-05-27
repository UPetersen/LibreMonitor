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
        case bluetoothDisconnected
        case someInfiniteLoop
        case lowBattery
        case bloodGlucoseHighOrLow
        case debug
    }
    
    static var timeFormatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH.mm.ss"
        return timeFormatter
    }()
    
    static func authorize(delegate: UNUserNotificationCenterDelegate) {
    
        let center = UNUserNotificationCenter.current()
        center.delegate = delegate
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                //  application.registerForRemoteNotifications()
            }
        }
    }

    
    // MARK: - badge icon number
    
    /// Sets application badge icon
    ///
    /// - Parameter value: badge icon number. 0 ... nothing displayed
    static func applicationIconBadgeNumber(value: Int) {
        UIApplication.shared.applicationIconBadgeNumber = value
    }

    
    // MARK: - Local Notifications
    
    /// Bluetooth disconnected local notification.
    /// Can be withheld for some waiting time and be removed within that time frame if a reconnection occurs.
    /// - Parameter wait: time to wait until notification is displayed. Default: 1s.
    static func scheduleBluetoothDisconnectedNotification(wait: TimeInterval = 1) {
        
        let content = UNMutableNotificationContent()
        content.title = "LibreMonitor disconnected"
        content.subtitle = ""
        content.body = "LibreMonitor disconnected at \(timeFormatter.string(from: Date())) hours."
        content.badge = 0
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: wait, repeats: false)
        let request = UNNotificationRequest(
            identifier: Category.bluetoothDisconnected.rawValue,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    static func removePendingBluetoothDisconnectedNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Category.bluetoothDisconnected.rawValue])
    }
    
    
    /// Low battery local notification.
    /// - Parameter voltage: Current battery voltage.
    static func setLowBatteryNotification(voltage: Double) {
        
        let content = UNMutableNotificationContent()
        content.title = "Low battery"
        content.subtitle = ""
        content.body = "Battery voltage is \(voltage)"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: Category.lowBattery.rawValue,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    /// Blood glucose high of low notification
    ///
    /// - Parameters:
    ///   - title: notification title to display
    ///   - body: notification body to display
    static func setBloodGlucoseHighOrLowNotification(title: String, body: String) -> Void {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = "Notification Subtitle"
        content.body = body
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: Category.bloodGlucoseHighOrLow.rawValue,
            content: content,
            trigger: trigger
        )

//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        // Deliver notification only if there was no delivered notification within the last n minutes
        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: {deliveredNotifcations in
            for deliveredNotifcation in deliveredNotifcations {
                if deliveredNotifcation.request.identifier == Category.bloodGlucoseHighOrLow.rawValue, Date().timeIntervalSince(deliveredNotifcation.date) < 8.0 * 60.0 {
                    return // there is a delivered notification within the time frame, so just return (and thus do not add the new notification)
                }
            }
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        })


    }
    
//    static func notificationDeliveredRecently(withIn: TimeInterval, category: Category) -> UNNotification? {
//        
//        var notification: UNNotification? = nil
//        // get delivered notifications for category
//        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: {deliveredNotifcations in
//            for deliveredNotifcation in deliveredNotifcations {
//                if deliveredNotifcation.request.identifier == category.rawValue, Date().timeIntervalSince(deliveredNotifcation.date) < 10.0*60.0 {
//                    notification = deliveredNotifcation
//                }
//            }
//        })
//        return notification
//    }
//    
    
    // MARK: - Local Notifications used for debugging
    
    
    /// Debug notifications used to find bugs like potential endless loops. This notification is scheduled for some time ahead (e.g. in two minutes)
    /// and is rescheduled when new data arrives. It thus only fires, if the normal data flow is interrupted, e.g. due to disconnection or an endless loop somewhere.
    ///
    /// - Parameters:
    ///   - message: message to display as notification body
    ///   - wait: time to wait before notification is delivered
    static func scheduleDebugNotification(message: String, wait: TimeInterval) {
        
        let content = UNMutableNotificationContent()
        content.title = "DebugTimer"
        content.subtitle = "Something took too long (\(wait) s):"
        content.body = message
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: wait, repeats: false)
        
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

