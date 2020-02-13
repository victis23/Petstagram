//
//  Keys.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import Foundation

/// Contains keys for various objects and operations. 
struct Keys {
	
	// Keys that handle segue actions.
	struct Segues {
		static var accessSegue = "accessSegue"
		static var signOut = "unwindToLogin"
		static var imageViewer = "imageViewer"
		static var otherUsers = "otherUsers"
	}
	
	// Keys that handle errors.
	struct ErrorKeys {
		static var loginFailed = "loginError"
		static var accountCreationFailed = "failedCreation"
	}
	
	// Keys for Google Firebase items.
	struct GoogleFireStore {
		
		// Account information for selected profile.
		static var accountInfoDocument = "accountInfo"
		
		// Key required to access an account username for specified uid.
		static var usernameKey = "Username"
		
		// Key for collection that contains a list of all users in database.
		static var userCollection = "Users"
		
		// Key for file that contains the keys for all users (username:UID)
		static var userKeysDocument = "UserKeys"
	}
	
	// Keys for Google Firebase Storage.
	struct GoogleStorage {
		static var imageDataArray = "ImageDataArray"
	}
	
	// Keys for userDefaults Database.
	struct userDefaultsDB {
		static var profilePhoto = "profilePhoto"
		static var username = "userName"
		static var imageCount = "imageCount"
	}
	
	// Keys for secure keychain.
	struct keyChainKeys {
		static var email = "email"
	}
}
