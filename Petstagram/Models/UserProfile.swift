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
import Firebase

class UserProfile {
	
	var username : String?
	var imageData : [Data]?
	let user = Auth.auth().currentUser?.uid
	let db = Firestore.firestore()
	
	static private var sharedUserProfile = UserProfile()
	
	private init(){
		self.username = String()
		self.imageData = []
		
		print("New Instance \(self.username ?? "No Username") | \(self.imageData ?? [])")
	}
	
	func saveImageDataToCloud(){
		guard let user = self.user else {fatalError()}
		guard let images = self.imageData else {fatalError()}
		let db = self.db
		
		db.collection(user).document(Keys.GoogleFireStore.accountImagesDocument).setData([
			Keys.GoogleFireStore.images : images
		], merge: true, completion: {_ in
			
			print("\(images) have been uploaded to Google FireStore!")
			
		})
		
	}
	
	func getImagesFromCloud() {
		
		guard let user = self.user else {fatalError()}
		
		db.collection(user)
			.document(Keys.GoogleFireStore.accountImagesDocument)
			.getDocument(source: .default) { (data, error) in
				if let error = error {
					print(error.localizedDescription)
					return
				}
				
				guard let data = data else {fatalError()}
				self.imageData = data[Keys.GoogleFireStore.images] as? [Data]
				
		}
		
//		db.collection(user).document(Keys.GoogleFireStore.accountImagesDocument).addSnapshotListener(includeMetadataChanges: true) { (snapShot, error) in
//			if let error = error {
//				print(error.localizedDescription)
//				return
//			}
//			snapShot.flatMap({
//				self.imageData = $0[Keys.GoogleFireStore.images] as? [Data]
//			})
//		}
	}
	
	static func shared() -> UserProfile {
		return sharedUserProfile
	}
	
}
