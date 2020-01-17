//
//  AuthenticationModel.swift
//  Petstagram
//
//  Created by Scott Leonard on 12/8/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Handles Authentication with Firebase & Updates Database for new users.
struct Authentication {
	var email :String
	var password :String
	var userName :String?
	
	
	/// Principal method used for authentication of users — Honestly, probably violates SOLID
	/// - Parameters:
	///   - isRegistration: Bool that determines if user is creating a new account or signing in.
	///   - isError: Captures Errors if any.
	///   - segue: Captures `AuthDataResult` and allows caller to use it possibly in a segue.
	/// - Important: This method also **saves user creds to keychain and username to userDefaults**.
	func firebaseUserRegistration(isRegistration: Bool,isError: @escaping (_ error : Error)->(Void) ,segue : @escaping (_ result: AuthDataResult)->())throws{
		
		let firebaseAuthentication = Auth.auth()
		
		switch isRegistration {
		case true:
			firebaseAuthentication.createUser(withEmail: email, password: password) { (result, error) in
				if let error = error {
					isError(error)
					return
				}
				guard let result = result else {return}
				
				// Saves user email to userDefaults
				let userDefaults = UserDefaults()
				userDefaults.set(self.email, forKey: Keys.keyChainKeys.email)
				
				// Saves user creds to keychain.
				Authentication.saveCredsToKeyChain(using: self.email, password: self.password)
				segue(result)
			}
		case false:
			firebaseAuthentication.signIn(withEmail: email, password: password) { (result, error) in
				if let error = error {
					isError(error)
					return
				}
				guard let result = result else {return}
				
				// Saves user email to userDefaults
				let userDefaults = UserDefaults()
				userDefaults.set(self.email, forKey: Keys.keyChainKeys.email)
				
				// Saves user creds to keychain.
				Authentication.saveCredsToKeyChain(using: self.email, password: self.password)
				segue(result)
			}
		}
		
	}
	
	
	/// Writes username to file in database that houses the user's account information
	/// - Important: Also writes to the database's main file that houses a list of all usernames and their cooresponding userIDs.
	func createUserNameOnServer(){
		
		guard let userName = userName else {return}
		guard let userID = Auth.auth().currentUser?.uid else {fatalError()}
		
		let db = Firestore.firestore()
		
		// Writes
		db.collection(userID).document(Keys.GoogleFireStore.accountInfoDocument).setData([
			Keys.GoogleFireStore.usernameKey : userName
		]) { (error) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
		
		//Writes username to database file that has keys for Usernames:ID's
		db.collection(Keys.GoogleFireStore.userCollection).document(Keys.GoogleFireStore.userKeysDocument).setData([
			userName:userID
		], merge: true) { error in
			if let error = error {
				print(error.localizedDescription)
			}
		}
		
	}
}
