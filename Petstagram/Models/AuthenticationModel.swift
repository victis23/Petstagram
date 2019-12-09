//
//  AuthenticationModel.swift
//  Petstagram
//
//  Created by Scott Leonard on 12/8/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import Foundation
import CryptoKit
import FirebaseAuth

struct Authentication {
	var email :String
	var password :String
	var userName :String
	
	func firebaseUserRegistration(isRegistration: Bool, segue : @escaping (_ result: AuthDataResult)->()){
		let firebaseAuthentication = Auth.auth()
		
		switch isRegistration {
		case true:
			firebaseAuthentication.createUser(withEmail: userName, password: password) { (result, error) in
				if let error = error {
					print(error.localizedDescription)
					return
				}
				guard let result = result else {return}
				segue(result)
			}
		default:
			firebaseAuthentication.signIn(withEmail: userName, password: password) { (result, error) in
				if let error = error {
					print(error.localizedDescription)
					return
				}
				guard let result = result else {return}
				segue(result)
			}
		}
	}
}
