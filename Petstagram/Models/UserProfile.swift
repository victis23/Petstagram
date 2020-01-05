//
//  UserProfile.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/4/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserProfile {
	
	var username : String?
	var images : [Data]?
	let user = Auth.auth().currentUser?.uid
	let db = Firestore.firestore()
	
	static private var sharedUserProfile = UserProfile()
	
	private init(username: String? = "", imageData : [Data]? = []){
		self.username = username
		self.images = imageData
		
		print("New Instance \(self.username ?? "No Username") | \(self.images ?? [])")
	}
	
	func saveImageDataToCloud(){
		guard let user = self.user else {fatalError()}
		guard let images = self.images else {return}
		let db = self.db
		
		db.collection(user).document(Keys.GoogleFireStore.accountImagesDocument).setData([
			Keys.GoogleFireStore.images : images
		], completion: {_ in
			
			print("\(images) have been uploaded to Google FireStore!")
			
		})
		
	}
	
	func getImagesFromCloud() {
		
		guard let user = self.user else {fatalError()}
		let db = self.db
		
		db.collection(user).document(Keys.GoogleFireStore.accountImagesDocument).addSnapshotListener(includeMetadataChanges: true) { (snapShot, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			snapShot.flatMap({
				self.images = $0[Keys.GoogleFireStore.images] as? [Data]
			})
		}
	}
	
	static func shared() -> UserProfile {
		return sharedUserProfile
	}
	
}
