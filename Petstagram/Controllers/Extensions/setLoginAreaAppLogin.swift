//
//  File.swift
//  Petstagram
//
//  Created by Scott Leonard on 12/8/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit

///Handles attributes for views.
extension AppLogin {
	
	/// Handles attributes for submission buttons.
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
	}
	
	
	
	/// Handles attributes for all textfields.
	func setTextFieldDelegates(){
		
		[
			userNameTextField,
			emailAddressTextField,
			passwordTextField,
			createEmailTextField,
			createPasswordTextField,
			passwordConfirmationTextField
			].enumerated().forEach {
				$0.element?.tag = $0.offset
				$0.element?.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
				$0.element?.autocapitalizationType = .none
				$0.element?.textColor = .black
				$0.element?.font = UIFont.boldSystemFont(ofSize: 20)
		}
		//Password TextField Attributes.
		passwordTextField.textContentType = .password
		passwordTextField.isSecureTextEntry = true
		createPasswordTextField.textContentType = .newPassword
		createPasswordTextField.isSecureTextEntry = true
		passwordConfirmationTextField.textContentType = .newPassword
		passwordConfirmationTextField.isSecureTextEntry = true
		
		
		//MARK: PlaceHolder Text
		
		// Username & Password Placeholder Attributed Text
		let placeHolderAttributes : [NSAttributedString.Key:Any] = [
			NSAttributedString.Key.foregroundColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.2),
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)
		]
		
		// Password PlaceHolder Text (All toghether).
		passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes : placeHolderAttributes)
		
		// NSAttributed String For Username
		let usernamePlaceHolderText = NSAttributedString(string: "Email", attributes : placeHolderAttributes)
		// Username Placeholder Text — Seperated into two parts just for clarification purposes.
		emailAddressTextField.attributedPlaceholder = usernamePlaceHolderText
	}
}
