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
	let storage = Storage.storage().reference()
	
	
	static private var sharedUserProfile = UserProfile()
	
	private init(){
		self.username = String()
		self.imageData = []
		
		print("New Instance \(self.username ?? "No Username") | \(self.imageData ?? [])")
	}
	
	func uploadDataToFireBase(){
		guard let user = self.user else {fatalError()}
		guard let imageData = self.imageData else {return}
		let filePath = storage.child(user)
		
		imageData.forEach { data in
			filePath.child("\(data.hashValue)").putData(data)
		}
	}
	
	func downloadImages(downloadedImages : @escaping (_ imageKey : [String:UIImage])->Void) {
	
		var imageKey : [String:UIImage] = [:]
		
		guard let user = self.user else {fatalError()}
		
		let filePath = storage.child(user)
		
		filePath.listAll { (list, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			list.items.forEach { item in
				Storage.storage().reference(forURL: "\(item)").getData(maxSize: 999_999_999) { (data, error) in
					
					if let error = error {
						print(error.localizedDescription)
						return
					}
					
					guard let data = data, let image = UIImage(data: data) else {return}
					imageKey["\("\(item)".split(separator: "/")[3])"] = image
					downloadedImages(imageKey)
				}
			}
		}
	}
	
	
	static func shared() -> UserProfile {
		return sharedUserProfile
	}
	
}
