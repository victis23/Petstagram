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
	
	var imageData : Data?
	let user = Auth.auth().currentUser?.uid
	let db = Firestore.firestore()
	let storage = Storage.storage().reference()
	
	static private var sharedUserProfile = UserProfile()
	
	private init(){
		self.imageData = Data()
	}
	
	func uploadDataToFireBase(){
		
		guard let user = self.user else {fatalError()}
		guard let imageData = self.imageData else {return}
		
		let filePath = storage.child(user)
		filePath.child("\(imageData.hashValue)").putData(imageData)
		self.imageData = nil
	}
	
	func downloadImages(downloadedImages : @escaping (_ metaData : [StorageMetadata])->Void) {
		
		var metaDataKeys : [StorageMetadata] = []
		
		guard let user = self.user else {fatalError()}
		
		let filePath = storage.child(user)
		
		filePath.listAll { (list, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			list.items.forEach { item in
				Storage.storage().reference(forURL: "\(item)").getMetadata { (metaData, Error) in
					if let error = error {
						print(error.localizedDescription)
						return
					}
					if let metaData = metaData {
						
							metaDataKeys.append(metaData)
							downloadedImages(metaDataKeys)
					}
				}
			}
		}
	}
	
	
	static func shared() -> UserProfile {
		return sharedUserProfile
	}
	
}
