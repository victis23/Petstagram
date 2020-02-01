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

/// Singleton object that handles uploading and downloading images from storage.
class UserProfile {
	
	var imageData : Data?
	let user = Auth.auth().currentUser?.uid
	let db = Firestore.firestore()
	let storage = Storage.storage().reference()
	var imageCaption : String?
	
	static private var sharedUserProfile = UserProfile()
	
	// Creates empty data object and sets it to imageData.
	private init(){
		self.imageData = Data()
		self.imageCaption = String()
	}
	
	/// Uploads data storaged in `imageData` to Firebase Storage inside folder under userID.
	/// - Note: `imageData` is set to nil after each write.
	func uploadDataToFireBase(){
		
		guard let user = self.user else {fatalError()}
		guard let imageData = self.imageData else {return}
		
		let filePath = storage.child(user)
		filePath.child("\(imageData.hashValue)").putData(imageData)
		self.imageData = nil
	}
	
	/// Downloads **Metadata** for each item contained within Google Firebase Storage.
	/// - Parameter downloadedImages: Captures returned metadata array.
	func downloadImages(downloadedImages : @escaping (_ metaData : StorageMetadata)->Void) {
		
		guard let user = self.user else {fatalError()}
		
		// Variable holds path to user's storage bucket.
		let filePath = storage.child(user)
		
		filePath.listAll { (list, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			// For each item in the bucket method downloads its metadata and appends it to the metaDataKeys array.
			list.items.forEach { item in
				Storage.storage().reference(forURL: "\(item)").getMetadata { (metaData, Error) in
					if let error = error {
						print(error.localizedDescription)
						return
					}
					if let metaData = metaData {
						
						// Capture the returned metaData key.
						downloadedImages(metaData)
					}
				}
			}
		}
	}
	
	/// Creates instance of `UserProfile`
	static func shared() -> UserProfile {
		return sharedUserProfile
	}
	
}
