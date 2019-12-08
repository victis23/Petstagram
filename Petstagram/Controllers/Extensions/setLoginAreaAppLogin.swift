//
//  File.swift
//  Petstagram
//
//  Created by Scott Leonard on 12/8/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit

extension AppLogin {
	
	func setLoginArea(){
		
		// Login Layer
		let signInView = loginArea.layer
		signInView.cornerRadius = 15
		signInView.shadowOpacity = 0.35
		signInView.shadowOffset = CGSize(width: 5, height: 5)
		signInView.shadowRadius = 20
		
		// SignIn Button
		let signInButtonLayer = signInButton.layer
		signInButtonLayer.cornerRadius = 5
		
		// Username & Password TextFields.
		let placeHolderAttributes : [NSAttributedString.Key:Any] = [
			NSAttributedString.Key.foregroundColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.2),
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)
		]
		// NSAttributed String For Username
		let usernamePlaceHolderText = NSAttributedString(string: "Username", attributes : placeHolderAttributes)
		// Username Placeholder Text — Seperated into two parts just for clarification purposes.
		usernameTextField.attributedPlaceholder = usernamePlaceHolderText
		
		// Password PlaceHolder Text (All toghether).
		passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes : placeHolderAttributes)
		
		// Attributes for user input.
		usernameTextField.font = UIFont.boldSystemFont(ofSize: 20)
		passwordTextField.font = UIFont.boldSystemFont(ofSize: 20)
		passwordTextField.textContentType = .password
		passwordTextField.isSecureTextEntry = true
		
	}
}
