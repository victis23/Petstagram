//
//  AuthenticationModel.swift
//  Petstagram
//
//  Created by Scott Leonard on 12/8/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import Foundation
import FirebaseAuth

struct Authentication {
	var email :String
	var password :String
	var userName :String?
	var authentication : AuthCredential?
	
	func firebaseUserRegistration(isRegistration: Bool,isError: @escaping ()->(Void) ,segue : @escaping (_ result: AuthDataResult)->())throws{
	
		let firebaseAuthentication = Auth.auth()
		
		switch isRegistration {
		case true:
			firebaseAuthentication.createUser(withEmail: email, password: password) { (result, error) in
				if let error = error {
					isError()
					print(error.localizedDescription)
					return
				}
				guard let result = result else {return}
				segue(result)
			}
		default:
			firebaseAuthentication.signIn(withEmail: email, password: password) { (result, error) in
				if let error = error {
					isError()
					print(error.localizedDescription)
					return
				}
				guard let result = result else {return}
				segue(result)
			}
		}
		
	}
}
