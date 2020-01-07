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
	let storage = Storage.storage()
	var imageReferences : [String] = []
	
	
	static private var sharedUserProfile = UserProfile()
	
	private init(){
		self.username = String()
		self.imageData = []
		
		print("New Instance \(self.username ?? "No Username") | \(self.imageData ?? [])")
	}
	
//	func retrieveListOnLoad(){
//		guard let user = self.user else {fatalError()}
//
//		db.collection(user).document(Keys.GoogleFireStore.accountImagesDocument).getDocument { (document, error) in
//			if let error = error {
//				print(error.localizedDescription)
//				return
//			}
//			guard let imageKeys = document else {fatalError()}
//
//			if imageKeys.data() != nil {
//				return
//			}else{
//				self.imageReferences.append(contentsOf: imageKeys["imageKeys"] as! [String])
//			}
//		}
//	}
	
	func uploadDataToFireBase(){
		guard let user = self.user else {fatalError()}
		guard let imageData = self.imageData else {fatalError()}
		
		let dataFormat = DateFormatter()
		dataFormat.dateStyle = .long
		
		
		let root = storage.reference()
		
		imageData.enumerated().forEach({ count , data in
			let imgRef = "\(Keys.GoogleStorage.imageDataArray)\(dataFormat.string(from: Date()).hashValue)\(count)"
			imageReferences.append(imgRef)
			let reference = root.child(user).child(imgRef)
			reference.putData(data)
		})
		db.collection(user).document(Keys.GoogleFireStore.accountImagesDocument).setData([
			"imageKeys" : imageReferences
		], merge: false, completion: { _ in})
	}
	
	func downloadDataFromFireBase() {
		guard let user = self.user else {fatalError()}
		let file = storage.reference().child(user)
		var retrievedData : [Data] = []
		
		db.collection(user).document(Keys.GoogleFireStore.accountImagesDocument).getDocument { (document, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			guard let document = document else {fatalError()}
			guard let imageList = document["imageKeys"] as? [String] else {fatalError()}
			
			imageList.forEach { name in
				file.child(name).getData(maxSize: 9_999_999_999) { (data, error) in
					if let error = error {
						print(error.localizedDescription)
						return
					}
					guard let data = data else {fatalError()}
					retrievedData.append(data)
				}
			}
			self.imageData = retrievedData
		}
	}
	
	
	static func shared() -> UserProfile {
		return sharedUserProfile
	}
	
}
