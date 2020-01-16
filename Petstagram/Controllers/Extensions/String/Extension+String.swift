//
//  Extension+String.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/16/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {
	var isValidEmail : Bool {
		let wrappedEmail = Wrapped()
		return wrappedEmail.contains("@") && wrappedEmail.contains(".") && !wrappedEmail.isEmpty
	}
	
	var isValidPassword : Bool {
		let wrappedPassword = Wrapped()
		return (!wrappedPassword.isEmpty) && wrappedPassword != " "
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
