//
//  AppDelegate.swift
//  EncryptQR
//
//  Created by Lorenzo Rey Vergara on Sep 28, 2017.
//  Copyright © 2017 enzosv. All rights reserved.
//

import UIKit
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication,
	                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		DDTTYLogger.sharedInstance.logFormatter = CustomLogFormatter()

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = MainViewController()
		window?.makeKeyAndVisible()
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {

	}

	func applicationDidEnterBackground(_ application: UIApplication) {

	}

	func applicationWillEnterForeground(_ application: UIApplication) {
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
	}

	func applicationWillTerminate(_ application: UIApplication) {
	}

}
