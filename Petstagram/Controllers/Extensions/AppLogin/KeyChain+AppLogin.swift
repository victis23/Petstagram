//
//  KeyChain+AppLogin.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/11/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//



import Foundation
import Security

extension AppLogin  {
	
	/// Method that adds the account and password to icloud keychain.
	func savePasswordToKeychain(for email: String, password: String) throws {
		
		let account = email
		
		guard let encodedPassword = password.data(using: .utf8) else {throw SecureStoreError.string2DataConversionError}
		
		var query : [String : Any ]  = [:]
		
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
		
	}
	
	private func error(from status : OSStatus) -> SecureStoreError {
		
		let message = SecCopyErrorMessageString(status, nil) as String? ?? NSLocalizedString("Unhandled Error", comment: "")
		
		return SecureStoreError.unhandledError(message: message)
	}
}

public enum SecureStoreError: Error {
	case string2DataConversionError
	case data2StringConversionError
	case unhandledError(message: String)
}

extension SecureStoreError: LocalizedError {
	
	public var errorDescription: String? {
		
		switch self {
		case .string2DataConversionError:
			return NSLocalizedString("String to Data conversion error", comment: "")
		case .data2StringConversionError:
			return NSLocalizedString("Data to String conversion error", comment: "")
		case .unhandledError(let message):
			return NSLocalizedString(message, comment: "")
		}
	}
}
