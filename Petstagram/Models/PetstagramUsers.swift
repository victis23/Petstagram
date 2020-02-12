//
//  PetstagramUsers.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/12/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit


enum Section {
	case main
}

class PetstagramUsers : Hashable {
	
	static func == (lhs: PetstagramUsers, rhs: PetstagramUsers) -> Bool {
		lhs.uid == rhs.uid
	}
	
	var username: String
	var profileImage: UIImage?
	var uid : String
	
	init(_ username : String,_ uid : String, _ profileImage : UIImage?){
		self.username = username
		self.uid = uid
		self.profileImage = profileImage
	}
	
	func hash(into hasher : inout Hasher){
		hasher.combine(uid)
	}
}
