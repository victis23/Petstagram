//
//  AppDelegate.swift
//  Petstagram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import FirebaseAuth
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		
		let keyboardManger = IQKeyboardManager.shared
		keyboardManger.enable = true
		keyboardManger.enableAutoToolbar = false
		keyboardManger.shouldResignOnTouchOutside = true
		keyboardManger.keyboardDistanceFromTextField = 100
		
		FirebaseApp.configure()
		
		//MARK: - Core Data Implimentation
	
		let context = persistentContainer.viewContext
		var credSet : [String:String] = [:]
		
		let request = NSFetchRequest<AuthenticationItems>(entityName: "AuthenticationItems")
		guard let fetchedCollection = try? context.fetch(request) else {return true}
		fetchedCollection.forEach({
			credSet["email"] = $0.coreDataEmail
			credSet["password"] = $0.coreDataPassword
		})
		guard let username = credSet["email"] else {return true}
		guard let password = credSet["password"] else {return true}
		
		let firebaseAuth = Auth.auth()
		firebaseAuth.signIn(withEmail: username, password: password) { (result, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			print("User has signed In...")
			application.windows.first?.rootViewController?.performSegue(withIdentifier: Keys.Segues.accessSegue, sender: true)
		}
		return true
	}
	
	// MARK: UISceneSession Lifecycle
	
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
	
	// MARK: - Core Data stack
	
	lazy var persistentContainer: NSPersistentContainer = {
		
		let container = NSPersistentContainer(name: "Petstagram")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	
	// MARK:  Core Data Saving support
	
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
}

