//
//  Keys.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import Foundation

struct Keys {
	struct Segues {
		static var accessSegue = "accessSegue"
		static var signOut = "unwindToLogin"
	}
	struct ErrorKeys {
		static var loginFailed = "loginError"
		static var accountCreationFailed = "failedCreation"
	}
	struct GoogleFireStore {
		static var accountInfoDocument = "accountInfo"
		static var usernameKey = "Username"
		static var userCollection = "Users"
		static var userKeysDocument = "UserKeys"
		static var accountImagesDocument = "ImagesDocument"
		static var images = "images"
	}
}
