//
//  KeyChain+AppLogin.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/11/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//



import Foundation
import Security

protocol KeyChainHandler {
	var query : [String:Any] { get }
}

struct KeyChainWrapper  {
	
	let keyChainHandler : KeyChainHandler
	
	init(keyChainHandler : KeyChainHandler) {
		self.keyChainHandler = keyChainHandler
	}
	
	/// Method that adds the account and password to icloud keychain.
	func savePasswordToKeychain(for email: String?, password: String?) throws {
		
		guard
			let account = email,
			let password = password
			else {return}
		
		guard let encodedPassword = password.data(using: .utf8) else {throw SecureStoreError.string2DataConversionError}
		
		var query = keyChainHandler.query
		
		query[String(kSecAttrAccount)] = account
		
		var status = SecItemCopyMatching(query as CFDictionary, nil)
		
		switch status {
		case errSecSuccess:
			var attributeToUpdate : [String:Any] = [:]
			attributeToUpdate[String(kSecValueData)] = encodedPassword
			status = SecItemUpdate(query as CFDictionary, attributeToUpdate as CFDictionary)
			
			if status != errSecSuccess {
				throw error(from: status)
			}
		case errSecItemNotFound:
			query[String(kSecValueData)] = encodedPassword
			
			status = SecItemAdd(query as CFDictionary, nil)
			if status != errSecSuccess {
				throw error(from: status)
			}
		default:
			throw error(from: status)
		}
		
	}
	
	func retrievePasswordFromKeychain(for userAccount : String) throws -> String? {
		
		var query = keyChainHandler.query
		
//		let matchLimit = kSecMatchLimit as String
//		let returnAttributes = kSecReturnAttributes as String
//		let returnData = kSecReturnData as String
//		let attributedAccount = kSecAttrAccount as String
		
		
		query[String(kSecMatchLimit)] = kSecMatchLimitOne
		query[String(kSecReturnAttributes)] = kCFBooleanTrue
		query[String(kSecReturnData)] = kCFBooleanTrue
		query[String(kSecAttrAccount)] = userAccount
		
		var queryResult : AnyObject?
		
		let status = withUnsafeMutablePointer(to: &queryResult) {
			SecItemCopyMatching(query as CFDictionary, $0)
		}
		
		switch status {
		case errSecSuccess:
			guard
				let queriedItem = queryResult as? [String:Any],
				let passwordData = queriedItem[String(kSecValueData)] as? Data,
				let password = String(data: passwordData, encoding: .utf8)
				else {throw SecureStoreError.data2StringConversionError}
			return password
		case errSecItemNotFound:
			return nil
		default:
			throw error(from: status)
		}
		
	}
	
	private func error(from status : OSStatus) -> SecureStoreError {
		
		let message = SecCopyErrorMessageString(status, nil) as String? ?? NSLocalizedString("Unhandled Error", comment: "")
		
		return SecureStoreError.unhandledError(message: message)
	}
}
