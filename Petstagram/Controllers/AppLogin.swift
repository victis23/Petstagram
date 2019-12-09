//
//  ViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/5/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import Combine
import CoreData

class AppLogin: UIViewController{
	
	private let applicationDelegate = UIApplication.shared.delegate as! AppDelegate
	private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	let authenticationModel = AuthenticationItems()
	
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
		textfield.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
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
		textfield.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
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
		textfield.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
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
		textfield.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
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
	
	private var userNamePublisher : AnyPublisher<String?,Never>!
	private var emailPublisher : AnyPublisher<String?,Never>!
	private var passwordPublisher : AnyPublisher<String?,Never>!
	private var passwordConfirmationPublisher : AnyPublisher<String?,Never>!
	
	private var accountCreationPublisher : AnyPublisher<(String?,String?,String?,String?),Never>!
	
	private var userNameSubscriber : AnyCancellable!
	private var emailSubscriber : AnyCancellable!
	private var passwordSubscriber : AnyCancellable!
	private var confirmedPasswordSubscriber : AnyCancellable!
	
	
	//MARK:  App LifeCycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setLoginArea()
		setTextFieldDelegates()
		setupPublishers()
	}
	
	func setTextFieldDelegates(){
		[
			userNameTextField,
			emailAddressTextField,
			passwordTextField,
			createEmailTextField,
			createPasswordTextField,
			passwordConfirmationTextField
			].enumerated().forEach {
				//				$0.element?.delegate = self
				$0.element?.tag = $0.offset
		}
	}
	
	@IBAction func logInButtonTapped(_ sender: Any) {
		
		performSegue(withIdentifier: Keys.Segues.accessSegue, sender: nil)
	}
	
	/// Called when new users tap on button for account creation.
	@IBAction func userRequestsNewAccountCreationButtonTapped(_ sender: Any) {
		
		createViewForAccountCreation()
	}
	
	func setupPublishers(){
		userNamePublisher = createPublisher(publisher: $userName)
		emailPublisher = createPublisher(publisher: $email)
		passwordPublisher = createPublisher(publisher: $password)
		passwordConfirmationPublisher = createPublisher(publisher: $passwordConfirmation)
	}
	
	func createPublisher(publisher : Published<String?>.Publisher)->AnyPublisher<String?,Never>{
		
		let pub = publisher
			.debounce(for: 3, scheduler: DispatchQueue.global(qos: .background))
			.removeDuplicates()
			.eraseToAnyPublisher()
		return pub
	}
	
	@objc func createNewAccount(){
		
	}
	
	
}

extension AppLogin {

	@objc func textFieldValueChanged(_ textField: UITextField){
		let tag = textField.tag
		guard let text = textField.text else {return}
		
		switch tag {
		case 0:
			userName = text
		case 1:
			email = text
		case 2:
			password = text
		case 3:
			email = text
		case 4:
			password = text
		case 5:
			passwordConfirmation = text
		default:
			break
		}
	}
}






