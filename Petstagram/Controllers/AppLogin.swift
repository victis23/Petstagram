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
	@IBOutlet weak var emailAddressTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var logo: UILabel!
	
	let accountCreationUIView : UIView = {
		let uiView = UIView()
		uiView.layer.backgroundColor = UIColor.white.cgColor
		uiView.translatesAutoresizingMaskIntoConstraints = false
		uiView.layer.cornerRadius = 15
		uiView.layer.shadowOpacity = 0.35
		uiView.layer.shadowOffset = CGSize(width: 5, height: 5)
		uiView.layer.shadowRadius = 20
		return uiView
	}()
	let createEmailTextField : UITextField = {
		let textfield = UITextField()
		textfield.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.03)
		textfield.layer.borderColor = UIColor.tertiaryLabel.cgColor
		textfield.layer.borderWidth = 0.5
		textfield.layer.cornerRadius = 5
		textfield.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 10)
		textfield.translatesAutoresizingMaskIntoConstraints = false
		
		textfield.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
			NSAttributedString.Key.foregroundColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.1),
		])
		return textfield
	}()
	let userNameTextField : UITextField = {
		let textfield = UITextField()
		textfield.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.03)
		textfield.layer.borderColor = UIColor.tertiaryLabel.cgColor
		textfield.layer.borderWidth = 0.5
		textfield.layer.cornerRadius = 5
		textfield.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 10)
		textfield.translatesAutoresizingMaskIntoConstraints = false
		
		textfield.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
			NSAttributedString.Key.foregroundColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.1),
		])
		return textfield
	}()
	let createPasswordTextField : UITextField = {
		let textfield = UITextField()
		textfield.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.03)
		textfield.layer.borderColor = UIColor.tertiaryLabel.cgColor
		textfield.layer.borderWidth = 0.5
		textfield.layer.cornerRadius = 5
		textfield.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
			NSAttributedString.Key.foregroundColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.1),
		])
		textfield.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 10)
		textfield.translatesAutoresizingMaskIntoConstraints = false
		return textfield
	}()
	let passwordConfirmationTextField : UITextField = {
		let textfield = UITextField()
		textfield.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.03)
		textfield.layer.borderColor = UIColor.tertiaryLabel.cgColor
		textfield.layer.borderWidth = 0.5
		textfield.layer.cornerRadius = 5
		textfield.attributedPlaceholder = NSAttributedString(string: "Password Confirmation", attributes: [
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
			NSAttributedString.Key.foregroundColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.1),
		])
		textfield.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 10)
		textfield.translatesAutoresizingMaskIntoConstraints = false
		return textfield
	}()
	let submitButton : UIButton = {
		let button = UIButton()
		button.setAttributedTitle(NSAttributedString.init(string: "Create Account", attributes: [
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
			NSAttributedString.Key.foregroundColor : UIColor.white,
		]), for: .normal)
		button.layer.cornerRadius = 5
		button.backgroundColor = .systemBlue
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isEnabled = false
		button.alpha = 0.2
		button.addTarget(self, action: #selector(createNewAccount), for: .touchUpInside)
		return button
	}()
	
	//MARK: - Publishers & Subscribers
	
	@Published var email : String!
	@Published var password : String!
	@Published var passwordConfirmation : String!
	@Published var userName : String!
	private var mainPublisher : AnyPublisher<(String,String,String,String),Never>!
	private var emailSubscriber : AnyCancellable!
	private var passwordSubscriber : AnyCancellable!
	private var confirmedPasswordSubscriber : AnyCancellable!
	private var userNameSubscriber : AnyCancellable!
	
	//MARK:  App LifeCycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setLoginArea()
		setupPublishers()
	}
	
	@IBAction func logInButtonTapped(_ sender: Any) {
		
		performSegue(withIdentifier: Keys.Segues.accessSegue, sender: nil)
	}
	
	/// Called when new users tap on button for account creation.
	@IBAction func userRequestsNewAccountCreationButtonTapped(_ sender: Any) {
		
		createViewForAccountCreation()
	}
	
	func setupPublishers(){
		
	}
	
	@objc func createNewAccount(){
		
	}
	
}






