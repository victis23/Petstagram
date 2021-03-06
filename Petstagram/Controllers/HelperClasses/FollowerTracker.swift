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
	
	private var user : UserProfile
	private var follower : PetstagramUsers
	private var isFollowing : Bool
	private static let db = Firestore.firestore()
	private let defaults = UserDefaults()
	
	private var currentUser : (username:String,uid:String) {
		
		guard let user = user.user, let currentUserName = defaults.string(forKey: Keys.userDefaultsDB.username) else {fatalError()}
		return (currentUserName,user)
	}
	
	init(follower:PetstagramUsers, isFollowing:Bool) {
		self.user = UserProfile.shared()
		self.follower = follower
		self.isFollowing = isFollowing
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
		
		// Adds selected follower to user's follower list document.
		FollowerTracker.db.collection(currentUser.uid).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.following).setData([
			Keys.GoogleFireStore.following : [follower.username:follower.uid]
			], merge: true, completion: { error in
				
				if let error = error {
					print(error.localizedDescription)
				}
		})
		
		// Adds user to following list of user they are following.
		FollowerTracker.db.collection(follower.uid).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.followers).setData([
			Keys.GoogleFireStore.followers : [currentUser.username:currentUser.uid]
		], merge: true) { (error) in
			
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
	
	/// Removes followers from user's follower list and updates local state by re-uploading the modified file.
	/// - Note: The first method uses dot notation to access field user wants to remove. `["Following.username" : delete]`
	/// The second method which removes the current user from the follower list of the account in question actually downloads the entire document, converts it into a dictionary, removes the account information from the file and overwrites the existing document.
	func removeFollower(){
		
		// "Following.`account being removed`"
		FollowerTracker.db.collection(self.currentUser.uid).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.following).updateData(["\(Keys.GoogleFireStore.following).\(self.follower.username)":FieldValue.delete()], completion: { error in
			
			if let error = error {
				print(error.localizedDescription)
			}
		})
		
		// Remove current user as a follower on selected account.
		FollowerTracker.db.collection(follower.uid).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.followers).getDocument { (document, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			// Alternative and painful way to remove items from database. Kept here just to remind myself of how I originally did this.
			// Convert DocumentSnapshot into a common dictionary of type [String:Any] that is no longer and optional.
			guard let document = document, let unwrappedDocument = document.data() else {return}
			
			// Create instance of file that mutable.
			var file = unwrappedDocument
			// Access contained dictionary of type [String:String] using file["Followers"] key, where key = String(username), value = String(uid).
			var nestedFile = file[Keys.GoogleFireStore.followers] as! [String:String]
			// Remove all key/value pairs from file document.
			file.removeAll()
			// Remove PetstagramUser Object in question from retrieved dictionary [username:uid].
			nestedFile.removeValue(forKey: self.currentUser.username)
			// Write revised file back into empty dictionary file["Followers"] = [username:uid].
			file[Keys.GoogleFireStore.followers] = nestedFile
			// Write to database - replace existing file.
			FollowerTracker.self.db.collection(self.follower.uid).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.followers).setData(file, merge: false)
		}
		
	}
}

extension FollowerTracker {
	
	/// Retrieves the list of accounts the current user is following.
	static func getFollowingList(completion : @escaping ([String])->Void){
		
		guard let userID = UserProfile.shared().user else {return}
		
		let db = Firestore.firestore()
		
		db.collection(userID).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.following).getDocument { (document, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			guard let document = document,
				let documentDictionary = document.data(),
				let FollowingListDictionary = documentDictionary[Keys.GoogleFireStore.following] as? [String:String]
				else {return}
			
			let userUserIDs = FollowingListDictionary.map {$0.1}
			completion(userUserIDs)
		}
	}
	
	
	static func getFollowerCount(user: String, completion : @escaping (Int)->Void){
		
		db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.followers).getDocument { (document, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			guard let document = document?.data() else {return}
			completion((document[Keys.GoogleFireStore.followers] as! [String:String]).count)
		}
	}
	
	static func getFriendCount(user: String, completion: @escaping (Int)->Void){
		
		db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).collection(Keys.GoogleFireStore.friends).document(Keys.GoogleFireStore.following).getDocument { (document, error) in
			
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			guard let document = document?.data() else {return}
			completion((document[Keys.GoogleFireStore.following] as! [String:String]).count)
		}
	}
}
