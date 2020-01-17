//
//  ErrorHandler.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/12/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation

/// Handles errors that may present themselves while reading and writing values to user keychain.
public enum SecureStoreError: Error {
	case string2DataConversionError
	case data2StringConversionError
	case unhandledError(message: String)
}

/// Adds variable that replaces the default error descriptions for error cases. 
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
