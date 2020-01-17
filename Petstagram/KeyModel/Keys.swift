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
	}
	
	// Keys that handle errors.
	struct ErrorKeys {
		static var loginFailed = "loginError"
		static var accountCreationFailed = "failedCreation"
	}
	
	// Keys for Google Firebase items.
	struct GoogleFireStore {
		static var accountInfoDocument = "accountInfo"
		static var usernameKey = "Username"
		static var userCollection = "Users"
		static var userKeysDocument = "UserKeys"
		static var accountImagesDocument = "ImagesDocument"
		static var images = "images"
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
