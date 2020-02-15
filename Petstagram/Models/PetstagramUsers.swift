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
	var uid : String
	var image : UIImage?
	var following : Bool = false
	
	init(_ username : String,_ uid : String){
		self.username = username
		self.uid = uid
	}
	
	func hash(into hasher : inout Hasher){
		hasher.combine(uid)
	}
}


extension PetstagramUsers {
	
	func getProfileImages(){
		
	}
}
