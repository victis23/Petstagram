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
	
	func getFollowingList(){
		
	}
	
	func getFollowerList(){
		
	}
	
	/// Checks current state for selected account and runs updates database appropriately.
	/// - Note: Remember that the `isFollowing` property is the inverse of the actual state for each incoming object.
	func checkState(){
		
		if isFollowing {
			addFollower()
		}else{
			removeFollower()
		}
	}
	
	/// Writes to Firebase - Method updates the user's friends list and updates friend's followers list.
	func addFollower(){
		
		guard let user = user.user,
			let currentUsername = defaults.string(forKey: Keys.userDefaultsDB.username)
			else {return}
		
		// Adds selected follower to user's follower list document.
		db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.following).setData([
			Keys.GoogleFireStore.following : [follower.username:follower.uid]
		], merge: true, completion: { error in
			
			if let error = error {
				print(error.localizedDescription)
			}
		})
		
		// Adds user to following list of user they are following.
		db.collection(follower.uid).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.followers).setData([
			Keys.GoogleFireStore.followers : [currentUsername:user]
		], merge: true) { (error) in
			
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
	
	/// Removes followers from user's follower list and updates local state by re-uploading the modified file.
	func removeFollower(){
		
		guard let user = user.user,
			let currentUsername = defaults.string(forKey: Keys.userDefaultsDB.username)
			else {return}
		
		// Remove account from following list on current user's account.
		db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.following).getDocument { (document, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			// Convert DocumentSnapshot into a common dictionary of type [String:Any] that is no longer and optional.
			guard let document = document, let unwrappedDocument = document.data() else {return}
			
			// Create instance of file that mutable.
			var file = unwrappedDocument
			// Access contained dictionary of type [String:String] using file["Following"] key, where key = String(username), value = String(uid).
			var nestedFile = file[Keys.GoogleFireStore.following] as! [String:String]
			// Remove all key/value pairs from file document.
			file.removeAll()
			// Remove PetstagramUser Object in question from retrieved dictionary [username:uid].
			nestedFile.removeValue(forKey: self.follower.username)
			// Write revised file back into empty dictionary file["Following"] = [username:uid].
			file[Keys.GoogleFireStore.following] = nestedFile
			// Write to database - replace existing file.
			self.db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.following).setData(file, merge: false)
		}
		
		// Remove current user as a follower on selected account.
		db.collection(follower.uid).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.followers).getDocument { (document, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			// Same steps as above. 
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
