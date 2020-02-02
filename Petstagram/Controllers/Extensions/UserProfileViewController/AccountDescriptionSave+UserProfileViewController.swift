//
//  AccountDescriptionSave+UserProfileViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/2/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Methods for saving and retrieving profile description from firebase.
extension UserProfileViewController {
	
	/// Retrieves profile description.
	func getAccountDescription(){
		if let user = userAuth.currentUser?.uid {
			let db = Firestore.firestore()
			db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).getDocument { (document, error) in
				
				if let error = error {
					print(error.localizedDescription)
					return
				}
				
				if let data = document?.data() {
					let text = data["ProfileDescription"] as? String
					self.aboutThePetLabel.text = text
				}
			}
		}
	}
	
	/// Writes profile description to database.
	func saveAccountDescription(){
		
		if let user = userAuth.currentUser?.uid {
			let db = Firestore.firestore()
			db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).setData(
				[
					"ProfileDescription":"\(aboutThePetLabel.text ?? "")"
				]
			, merge: true) { (error) in
				if let error = error {
					print(error.localizedDescription)
					return
				}
			}
		}
	}
}
