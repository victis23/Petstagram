//
//  UserProfileImageCollectionModel.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/11/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit
import FirebaseStorage


/// Contains object that will be used in datasource snapshot on `UserProfileViewController`.
struct AccountImages : Hashable, Identifiable, Equatable {
	var image : UIImage
	var timeStamp : Date
	var metaData : StorageMetadata?
	var id :String
	
	func hash(into hasher : inout Hasher) {
		hasher.combine(id)
	}
	
	static func ==(lhs:AccountImages, rhs: AccountImages) -> Bool {
		lhs.id == rhs.id
	}
}
