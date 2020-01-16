//
//  Extension+String.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/16/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {

	var wrappedValue: String {
		get {
			return self ?? " "
		}
	}

	var isValidUserName : Bool {
		return !wrappedValue.isEmpty && wrappedValue.count > 3
	}

	var isValidEmail : Bool {
		print(wrappedValue)
		return wrappedValue.contains("@") && wrappedValue.contains(".") && !wrappedValue.isEmpty && wrappedValue != " "
	}


	var isValidPassword : Bool {
		print(wrappedValue)
		return (!wrappedValue.isEmpty && wrappedValue != " ")
	}
}

extension String {
	var isValidEmailAddress : Bool {
		self.contains("@") && self.contains(".") && !self.isEmpty
	}
	var isValidPasswordAddress : Bool {
		return (!self.isEmpty) && self != " "
	}
}
