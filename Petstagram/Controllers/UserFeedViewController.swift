//
//  UserFeedViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/6/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CoreData

class UserFeedViewController: UIViewController {

	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	var coreDataAuthModel : AuthenticationItems!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupCoreDataAuthModel()
		setupNavigation()
    }
	
	func setupCoreDataAuthModel(){
		coreDataAuthModel = AuthenticationItems(context: context)
	}
	
	func setupNavigation(){
		// used navigataion item title property instead of \.view.title because I dont want titles in tab bar.
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 35)!]
		
	}
	
	func createUserCollection() {
		
//		var userNameSet = Set<String>()
//
//		do {
//			let request = NSFetchRequest<AuthenticationItems>(entityName: "AuthenticationItems")
//			let authValues = try context.fetch(request)
//
//			authValues.forEach({
//				guard let username = $0.coreDataUserName else {return}
//				userNameSet.insert(username)
//			})
//
//		}catch(let authError){
//			print(authError.localizedDescription)
//		}
		
		guard let userName = Auth.auth().currentUser?.email else {return}
		
		let db = Firestore.firestore()
		db.collection(userName).document("accountInfo").setData([
			"Username" : userName
		]) { (error) in
			if let error = error {
				print(error)
			}
		}
	}

}
