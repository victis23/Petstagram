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
		
		let db = Firestore.firestore()
		let defaults = UserDefaults()
		
		guard let user = user.user,
			let currentUsername = defaults.string(forKey: Keys.userDefaultsDB.username)
			else {return}
		
		db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).collection("Friends").document("Following").setData([
			"Following" : [follower.username:follower.uid]
		], merge: true, completion: { error in
			if let error = error {
				print(error.localizedDescription)
			}
		})
		
		db.collection(follower.uid).document(Keys.GoogleFireStore.accountInfoDocument).collection("Friends").document("Followers").setData([
			"Follower" : [currentUsername:user]
		], merge: true) { (error) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
	
	func removeFollower(){
		
	}
	
}
