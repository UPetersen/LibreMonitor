//
//  AppDelegate.swift
//  LibreMonitor
//
//  Created by Uwe Petersen on 14.10.16.
//  Copyright © 2016 Uwe Petersen. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications
import CoreData
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    static let bt_log = OSLog(subsystem: "com.LibreMonitor", category: "AppDelegate")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
     
        
        // Allow local notifications for iOS 10
         NotificationManager.authorize(delegate: self)
        
        // Do not show a badge icon value unless data has been received
        UIApplication.shared.applicationIconBadgeNumber = 0 // hide badge number
   
        
        // Override point for customization after application launch.
//        let splitViewController = self.window!.rootViewController as! UISplitViewController
//        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
//        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
//        splitViewController.delegate = self
//
//        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
//        let controller = masterNavigationController.topViewController as! MasterViewController
//        controller.managedObjectContext = self.persistentContainer.viewContext
        
//        print("In didFinishLaunchingWithOptions")
        os_log("Application did finish launching with options", log: AppDelegate.bt_log, type: .default)

        
        let tabBarController = self.window?.rootViewController as! UITabBarController
        
        if let childViewControllers = tabBarController.viewControllers {
            
            for childViewController in childViewControllers where childViewController is UINavigationController {
                let navigationController = childViewController as! UINavigationController
                let bloodSugarTableViewController = navigationController.topViewController as! BloodSugarTableViewController
                
                // Set core data stack in view controller
                bloodSugarTableViewController.persistentContainer = self.persistentContainer
            }
        }
        
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let fileName = "\(Date()).log"
        let logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)
        freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stderr)
        freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stdout)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        os_log("Application will resign active", log: AppDelegate.bt_log, type: .default)
//        print("In applicationWillResignActive")
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        os_log("Application did enter background", log: AppDelegate.bt_log, type: .default)
//        print("In applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        os_log("Application will enter foreground", log: AppDelegate.bt_log, type: .default)
//        print("In applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        os_log("Application did become active", log: AppDelegate.bt_log, type: .default)
//        print("In applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        os_log("Application will terminate", log: AppDelegate.bt_log, type: .default)
//        print("In applicationWillTerminate")
        self.saveContext()
    }


    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "LibreMonitor")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                os_log("Persistend container could not be loaded", log: AppDelegate.bt_log, type: .error)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                os_log("Manged object context could not be loaded", log: AppDelegate.bt_log, type: .error)
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


}

