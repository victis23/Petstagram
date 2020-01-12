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

struct Authentication {
	var email :String
	var password :String
	var userName :String?
	
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
				
				let userDefaults = UserDefaults()
				userDefaults.set(self.email, forKey: Keys.keyChainKeys.email)
				Authentication.saveCredsToKeyChain(using: self.email, password: self.password)
				segue(result)
			}
		default:
			firebaseAuthentication.signIn(withEmail: email, password: password) { (result, error) in
				if let error = error {
					isError(error)
					return
				}
				guard let result = result else {return}
				
				let userDefaults = UserDefaults()
				userDefaults.set(self.email, forKey: Keys.keyChainKeys.email)
				Authentication.saveCredsToKeyChain(using: self.email, password: self.password)
				segue(result)
			}
		}
		
	}
	
	func createUserNameOnServer(){
		
		guard let userName = userName else {return}
		guard let userID = Auth.auth().currentUser?.uid else {fatalError()}
		
		let db = Firestore.firestore()
		
		// Adds document that will hold information for individual users.
		
		db.collection(userID).document(Keys.GoogleFireStore.accountInfoDocument).setData([
			Keys.GoogleFireStore.usernameKey : userName
		]) { (error) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
		
		// Adds new user information to document containing list of all existing users.
		
		db.collection(Keys.GoogleFireStore.userCollection).document(Keys.GoogleFireStore.userKeysDocument).setData([
			userName:userID
		], merge: true) { error in
			if let error = error {
				print(error.localizedDescription)
			}
		}
		
	}
}
