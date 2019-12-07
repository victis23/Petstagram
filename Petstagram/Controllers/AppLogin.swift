//
//  ViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/5/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import Combine

class AppLogin: UIViewController {
	
	@IBOutlet weak var loginArea: UIView!
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	
	var userNameSubscriber : AnyCancellable!
	var passwordSubscriber : AnyCancellable!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setLoginArea()
	}
	
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
	
	@IBAction func logInButtonTapped(_ sender: Any) {
		performSegue(withIdentifier: Keys.Segues.accessSegue, sender: nil)
	}
	
	@IBAction func createAnAccount(_ sender: Any) {
		UIView.animate(withDuration: 2.0) {
			self.loginArea.transform = CGAffineTransform(translationX: 0, y: -500)
		}
		createViewForAccountCreation()
	}
	
	func createViewForAccountCreation(){
		let accountCreationUIView : UIView = {
			
			let uiView = UIView(frame: CGRect(x: 0, y: 0, width: loginArea.frame.width, height: loginArea.frame.height))
			uiView.translatesAutoresizingMaskIntoConstraints = false
			return uiView
		}()
		
		view.addSubview(accountCreationUIView)
		
		NSLayoutConstraint.activate([
			accountCreationUIView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			accountCreationUIView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -166)
		])
	}
	
}




