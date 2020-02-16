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
	
	var user : String
	var follower : String
	var isFollowing : Bool
	
	init(user:String, follower:String, isFollowing:Bool) {
		self.user = user
		self.follower = follower
		self.isFollowing = isFollowing
	}
	
	/// Writes to Firebase - Method updates the user's friends list and updates friend's followers list.
	func addFollower(){
		
		let db = Firestore.firestore()
		
		db.collection(user).document(Keys.GoogleFireStore.accountInfoDocument).collection("Friends").document("Following").setData([
			"Following" : follower
		], merge: true, completion: { error in
			if let error = error {
				print(error.localizedDescription)
			}
		})
		
		db.collection(follower).document(Keys.GoogleFireStore.accountInfoDocument).collection("Friends").document("Followers").setData([
			"Follower" : user
		], merge: true) { (error) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
	
	func removeFollower(){
		
	}
	
}
