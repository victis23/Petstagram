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
		
		guard let userName = Auth.auth().currentUser?.displayName else {fatalError()}
		
		let db = Firestore.firestore()
		db.collection(userName).document("accountInfo").setData([
			"Username" : userName
		]) { (error) in
			if let error = error {
				print(error)
			}
		}
		
		db.collection(userName).addDocument(data: ["Test":"Test"])
	}

}
