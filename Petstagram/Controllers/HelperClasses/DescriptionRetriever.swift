//
//  DescriptionRetriever.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/15/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class DescriptionRetriever {
	
	let db = Firestore.firestore()
	let storage = Storage.storage()
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
	
	/// Searches online storage for profile photo that cooresponds to the provided Uid.
	/// - Parameters:
	///   - completion: Captures Image returned from GoogleFirebase Storage.
	func getProfilePhoto( completion : @escaping (UIImage)->Void) {
		
		storage.reference().child(userID).child("profilePhoto").getData(maxSize: 99_999_999) { (data, error) in
			
			if let error = error {
				print(error.localizedDescription)
			}
			
			guard let data = data, let image = UIImage(data: data) else {return}
			completion(image)
		}
	}
	
	init(userID:String){
		self.userID = userID
	}
}
