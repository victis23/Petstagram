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
	
	func downloadImages(downloadedImages : @escaping (_ imageKey : [String:UIImage], _ metaData : [StorageMetadata])->Void) {
		
		var imageKey : [String:UIImage] = [:]
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
						
						Storage.storage().reference(forURL: "\(item)").getData(maxSize: 9_999_999) { (data, error) in
							
							if let error = error {
								print(error.localizedDescription)
								return
							}
							
							guard let data = data, let image = UIImage(data: data) else {return}
							imageKey["\("\(item)".split(separator: "/")[3])"] = image
							metaDataKeys.append(metaData)
							
							print("\(metaData) | \("\(item)".split(separator: "/")[3])")
							downloadedImages(imageKey, metaDataKeys)
						}
					}
				}
			}
		}
	}
	
	
	static func shared() -> UserProfile {
		return sharedUserProfile
	}
	
}
