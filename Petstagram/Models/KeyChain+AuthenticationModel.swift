//
//  KeyChain+AuthenticationModel.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/12/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation

/// Extends `Authentication` class with methods that can call items from the user keychain. 
extension Authentication {
	
	/// Collects two strings adn passes them into a function call that will try to save them to the keychain.
	/// - Note: `GenericPassword` is a struct that conforms to the `KeyChainHandler` Protocol.
	static func saveCredsToKeyChain(using email:String, password:String) {
		
		let keychainWrapper = GenericPassword(service: "Petstagram", accessGroup: nil)
		let storage = KeyChainWrapper(keyChainHandler: keychainWrapper)
		
		do{
			try storage.savePasswordToKeychain(for: email, password: password)
		}catch(let e){
			print(e.localizedDescription)
		}
	}
	
	/// Retrieves a user's email address from UserDefaults and tries to add it to a funcion call that will retrieve a user's unencrypted password from the keychain.
	///  - Returns: String which cooresponds to user's password.
	/// - Note: `GenericPassword` is a struct that conforms to the `KeyChainHandler` Protocol.
	static func retrieveCredsFromKeychain() -> String {
		
		let keychainWrapper = GenericPassword(service: "Petstagram", accessGroup: nil)
		let storage = KeyChainWrapper(keyChainHandler: keychainWrapper)
		
		let userDefaults = UserDefaults()
		let email = userDefaults.string(forKey: Keys.keyChainKeys.email)
		
		var password : String = "No Value For Password!"
		
		if let email = email {
			do {
				guard let retrievedPassword = try storage.retrievePasswordFromKeychain(for: email) else {return "Failed To Retrieve using \(email)"}
				password = retrievedPassword
			}catch(let e){
				print(e.localizedDescription)
			}
		}
		return password
	}
	
	/// Tries to call method that will remove everything from user's keychain.
	static func removeCredsFromKeyChain() {
		
		let keychainWrapper = GenericPassword(service: "Petstagram", accessGroup: nil)
		let storage = KeyChainWrapper(keyChainHandler: keychainWrapper)
		
		do {
			try storage.removeFromKeyChain()
		}catch(let e){
			print(e.localizedDescription)
		}
	}
	
}
