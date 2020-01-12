//
//  KeyChain+AuthenticationModel.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/12/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation

extension Authentication {
	
	static func saveCredsToKeyChain(using email:String, password:String) {
		
		let keychainWrapper = GenericPassword(service: "Petstagram", accessGroup: nil)
		let storage = KeyChainWrapper(keyChainHandler: keychainWrapper)
		
		do{
		try storage.savePasswordToKeychain(for: email, password: password)
		}catch(let e){
			print(e.localizedDescription)
		}
	}
	
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
}
