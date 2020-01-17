//
//  KeyChain+AppLogin.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/11/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//



import Foundation
import Security

/// Sets requirement for a **read-only** computed property dictionary  [String:Any]
protocol KeyChainHandler {
	var query : [String:Any] { get }
}

//MARK: - Generic Password

struct GenericPassword : KeyChainHandler {
	
	let service : String
	let accessGroup : String?
	
	// Conformance to KeyChainHander requiremnet for a computed property of type [String:Any].
	var query: [String : Any] {
		
		var query : [String : Any] = [:]
		
		// Set class to Generic Password
		query[String(kSecClass)] = kSecClassGenericPassword
		query[String(kSecAttrService)] = service
		
		// Access Group is set to nil because this is the only app that requires access to the items in this service.
		if let accessGroup = accessGroup {
			query[String(kSecAttrAccessGroup)] = accessGroup
		}
		return query
	}
	
	init(service : String, accessGroup : String? = nil) {
		self.service = service
		self.accessGroup = accessGroup
	}
}

//MARK: - Keychain Wrapper

/// Houses methods that are charged with `CRUD` on keychain.
struct KeyChainWrapper  {
	
	let keyChainHandler : KeyChainHandler
	
	/// Excepts any object that conforms to protocol `KeyChainHandler`.
	init(keyChainHandler : KeyChainHandler) {
		self.keyChainHandler = keyChainHandler
	}
	
	/// Basic Keychain Management.
	/// - [C]: Creates account if it does not already exist and writes data to keychain.
	/// - [U]: If account already exists, this method writes updated password to keychain.
	/// - Parameters:
	///   - email: Email input from user.
	///   - password: Password input from user.
	func savePasswordToKeychain(for email: String?, password: String?) throws {
		
		guard
			let account = email,
			let password = password
			else {return}
		
		// Encript password string using .UTF8 throws error if operation fails.
		guard let encodedPassword = password.data(using: .utf8) else {throw SecureStoreError.string2DataConversionError}
		
		// Stored property accesses query held by KeyChainHandler conforming Object.
		// Query already contains 2 key value pairs: kSecClass & kSecAttrService.
		var query = keyChainHandler.query
		
		// Add new key value pair: kSecAttrAccount : account (user's email)
		query[String(kSecAttrAccount)] = account
		
		// Check Secury Item Database for matching query.
		var status = SecItemCopyMatching(query as CFDictionary, nil)
		
		switch status {
		//Key for account was found.
		case errSecSuccess:
			var attributeToUpdate : [String:Any] = [:]
			
			// Update existing key for password.
			attributeToUpdate[String(kSecValueData)] = encodedPassword
			status = SecItemUpdate(query as CFDictionary, attributeToUpdate as CFDictionary)
			
			if status != errSecSuccess {
				throw error(from: status)
			}
		// Key for account was not found.
		case errSecItemNotFound:
			query[String(kSecValueData)] = encodedPassword
			
			// Add contents of query to dictionary (kSecValueData, kSecAttrAccount).
			status = SecItemAdd(query as CFDictionary, nil)
			if status != errSecSuccess {
				throw error(from: status)
			}
		default:
			throw error(from: status)
		}
		
	}
	
	/// - [R]: Queries and reads data stored in keychain.
	/// - Parameter userAccount: Email Retrieved by calling method.
	/// - Returns: Optional<String> Which should correspond to user's password.
	func retrievePasswordFromKeychain(for userAccount : String) throws -> String? {
		
		// Stored property accesses query held by KeyChainHandler conforming Object.
		// Query already contains 2 key value pairs: kSecClass & kSecAttrService.
		var query = keyChainHandler.query
		
		// How many matches we want to return.
		let matchLimit = kSecMatchLimit as String
		// Do we want to return attributes (BOOL)?
		let returnAttributes = kSecReturnAttributes as String
		// Do we want to return data (BOOL)?
		let returnData = kSecReturnData as String
		// Attributed accout to locate.
		let attributedAccount = kSecAttrAccount as String
		
		// Specify and add items to dictionary.
		query[matchLimit] = kSecMatchLimitOne
		query[returnAttributes] = kCFBooleanTrue
		query[returnData] = kCFBooleanTrue
		query[attributedAccount] = userAccount
		
		/* Alternate way of wrapping a CFString into just an ordinary String.
				query[String(kSecMatchLimit)] = kSecMatchLimitOne
				query[String(kSecReturnAttributes)] = kCFBooleanTrue
				query[String(kSecReturnData)] = kCFBooleanTrue
				query[String(kSecAttrAccount)] = userAccount
		*/
		
		// Stored property that will hold the results of query.
		var queryResult : AnyObject?
		
		let status = withUnsafeMutablePointer(to: &queryResult) {
			
			// $0 = UnsafeMutablePointer<AnyObject?>
			// Optional<AnyObject> is of type kSecValueData I think...
			SecItemCopyMatching(query as CFDictionary, $0)
		}
		
		switch status {
		case errSecSuccess:
			
			guard
				
				// Cast queryResult from AnyObject Optional to a dictionary.
				let queriedItem = queryResult as? [String:Any],
				
				// Retrieve data from kSecValueData key.
				let passwordData = queriedItem[String(kSecValueData)] as? Data,
				
				// Decode data into a string.
				let password = String(data: passwordData, encoding: .utf8)
				
				else {throw SecureStoreError.data2StringConversionError}
			return password
		case errSecItemNotFound:
			return nil
		default:
			throw error(from: status)
		}
		
	}
	/// - [D]: Securly removes all items from keychain.
	func removeFromKeyChain() throws {
		
		let query = keyChainHandler.query
		
		let status = SecItemDelete(query as CFDictionary)
		
		// If status doesn't equal success or Item not found throw error.
		guard status == errSecSuccess || status == errSecItemNotFound else {
			throw error(from: status)
		}
	}
	
	/// Error handling for our keychain methods.
	/// - Returns: A `SecureStoreError` Enum case.
	private func error(from status : OSStatus) -> SecureStoreError {
		
		let message = SecCopyErrorMessageString(status, nil) as String? ?? NSLocalizedString("Unhandled Error", comment: "")
		
		return SecureStoreError.unhandledError(message: message)
	}
}
