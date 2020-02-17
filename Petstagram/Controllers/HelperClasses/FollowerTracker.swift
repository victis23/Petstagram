//
//  FollowerTracker.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/16/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FollowerTracker {
	
	var user : UserProfile
	var follower : PetstagramUsers
	var isFollowing : Bool
	let db = Firestore.firestore()
	let defaults = UserDefaults()
	
	init(follower:PetstagramUsers, isFollowing:Bool) {
		self.user = UserProfile.shared()
		self.follower = follower
		self.isFollowing = isFollowing
	}
	
	func checkState(){
		
		if isFollowing {
			addFollower()
			return
		}
		
		removeFollower()
	}
	
	/// Writes to Firebase - Method updates the user's friends list and updates friend's followers list.
	func addFollower(){
		
		guard let user = user.user,
			let currentUsername = defaults.string(forKey: Keys.userDefaultsDB.username)
			else {return}
		
		db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.following).setData([
			Keys.GoogleFireStore.following : [follower.username:follower.uid]
		], merge: true, completion: { error in
			if let error = error {
				print(error.localizedDescription)
			}
		})
		
		db.collection(follower.uid).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.followers).setData([
			Keys.GoogleFireStore.followers : [currentUsername:user]
		], merge: true) { (error) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
	
	func removeFollower(){
		
		guard let user = user.user,
			let currentUsername = defaults.string(forKey: Keys.userDefaultsDB.username)
			else {return}
		
		db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.following).getDocument { (document, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			guard let document = document, let unwrappedDocument = document.data() else {return}
			
			var file = unwrappedDocument
			var nestedFile = file[Keys.GoogleFireStore.following] as! [String:String]
			file.removeAll()
			nestedFile.removeValue(forKey: self.follower.username)
			file[Keys.GoogleFireStore.following] = nestedFile
			self.db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.following).setData(file, merge: false)
		}
		
		db.collection(follower.uid).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.followers).getDocument { (document, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			guard let document = document, let unwrappedDocument = document.data() else {return}
			
			var file = unwrappedDocument
			var nestedFile = file[Keys.GoogleFireStore.followers] as! [String:String]
			file.removeAll()
			nestedFile.removeValue(forKey: currentUsername)
			file[Keys.GoogleFireStore.followers] = nestedFile
			self.db.collection(self.follower.uid).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.followers).setData(file, merge: false)
		}
		
	}
	
}
