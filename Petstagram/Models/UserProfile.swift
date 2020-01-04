//
//  UserProfile.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/4/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation

class UserProfile {
	
	var username : String?
	var images : [Data]?
	
	static private var sharedUserProfile = UserProfile()
	
	private init(username: String? = "", images: [Data]? = []){
		self.username = username
		self.images = images
	}
	
	static func shared() -> UserProfile {
		return sharedUserProfile
	}
	
}
