//
//  DescriptionRetriever.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/15/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation
import FirebaseFirestore

class DescriptionRetriever {
	
	let db = Firestore.firestore()
	var userID : String
	
	func getDescription(completion : @escaping (String?)->Void) {
		db.collection(userID).document(Keys.GoogleFireStore.accountInfoDocument).getDocument { (document, error) in
			
			guard error == nil else {
				guard let error = error else {return}
				print(error.localizedDescription)
				return
			}
			guard let document = document else {return}
			let description = document["ProfileDescription"] as? String
			completion(description)
		}
	}
	
	func getUserName(completion: @escaping (String)->Void){
		
		let defaults = UserDefaults()
		
		db.collection(userID).document(Keys.GoogleFireStore.accountInfoDocument).getDocument { (usernameDocument, error) in
			if let error = error {
				print(error.localizedDescription)
			}
			guard
				let usernameDocument = usernameDocument,
				let retrievedUserName = usernameDocument[Keys.GoogleFireStore.usernameKey] as? String
				else {fatalError()}
			
			defaults.set(retrievedUserName, forKey: Keys.userDefaultsDB.username)
			
			completion(retrievedUserName)
		}
	}
	
	init(userID:String){
		self.userID = userID
	}
}
