//
//  UserProfileImageCollectionModel.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/11/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

struct UserProfileImageCollection : Hashable, Identifiable, Equatable {
	var image : UIImage
	var timeStamp : Date
	var id :String
	
	func hash(into hasher : inout Hasher) {
		hasher.combine(id)
	}
	
	static func ==(lhs:UserProfileImageCollection, rhs: UserProfileImageCollection) -> Bool {
		lhs.id == rhs.id
	}
}
