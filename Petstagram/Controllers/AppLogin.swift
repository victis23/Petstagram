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
import FirebaseAuth

class AppLogin: UIViewController{
	
	private let applicationDelegate = UIApplication.shared.delegate as! AppDelegate
	private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	let coreDataAuthModel = AuthenticationItems()
	
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
	var createEmailTextField : UITextField! = {
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
	var userNameTextField : UITextField! = {
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
	var createPasswordTextField : UITextField! = {
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
	var passwordConfirmationTextField : UITextField! = {
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
	
	var userAuth : Authentication!
	
	@Published var email : String!
	@Published var password : String!
	@Published var submittedEmail : String!
	@Published var submittedPassword : String!
	@Published var passwordConfirmation : String!
	@Published var userName : String!
	
	private var userNamePublisher : AnyPublisher<String?,Never>!
	private var submittedEmailPublisher : AnyPublisher<String?,Never>!
	private var submittedPasswordPublisher : AnyPublisher<String?,Never>!
	private var passwordConfirmationPublisher : AnyPublisher<String?,Never>!
	private var emailPublisher : AnyPublisher<String?,Never>!
	private var passwordPublisher : AnyPublisher<String?,Never>!
	
	private var accountCreationPublisher : AnyPublisher<(String?,String?,String?,String?),Never>!
	private var signInPublisher : AnyPublisher<(String?,String?),Never>!
	
	var accountCreationSubscriber : AnyCancellable!
	var signInSubscriber : AnyCancellable!
	var signinError : AnyCancellable!
	var accountCreationError : AnyCancellable!
	
	//MARK:  App LifeCycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		signInButton.isEnabled = false
		signInButton.alpha = 0.2
		setLoginArea()
		setTextFieldDelegates()
		setupPublishers()
		setSubscribers()
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
				$0.element?.tag = $0.offset
				$0.element?.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
				$0.element?.autocapitalizationType = .none
				$0.element?.textColor = .black
				$0.element?.font = UIFont.boldSystemFont(ofSize: 20)
		}
	}
	
	/// Called when new users tap on button for account creation.
	@IBAction func userRequestsNewAccountCreationButtonTapped(_ sender: Any) {
		
		createViewForAccountCreation()
	}
	
	func setupPublishers(){
		userNamePublisher = createPublisher(publisher: $userName)
		submittedEmailPublisher = createPublisher(publisher: $submittedEmail)
		submittedPasswordPublisher = createPublisher(publisher: $submittedPassword)
		passwordConfirmationPublisher = createPublisher(publisher: $passwordConfirmation)
		emailPublisher = createPublisher(publisher: $email)
		passwordPublisher = createPublisher(publisher: $password)
		
		accountCreationPublisher = Publishers.CombineLatest4(userNamePublisher, submittedEmailPublisher, submittedPasswordPublisher, passwordConfirmationPublisher)
			.eraseToAnyPublisher()
		signInPublisher = Publishers.CombineLatest(emailPublisher, passwordPublisher)
			.eraseToAnyPublisher()
	}
	
	func setSubscribers(){
		
		accountCreationSubscriber = accountCreationPublisher
			.receive(on: DispatchQueue.main)
			.map({ [weak self](username, email, password, passwordConfirmation) -> Bool in
				if username != nil,email != nil,password != nil, passwordConfirmation != nil, username != "", email != "", password != "", passwordConfirmation != "", password == passwordConfirmation, email!.contains("@"){
					self?.submitButton.alpha = 1.0
					return true
				}else{
					self?.submitButton.alpha = 0.2
					return false
				}
			})
			.assign(to: \UIButton.isEnabled, on: submitButton)
		
		signInSubscriber = signInPublisher
			.receive(on: DispatchQueue.main)
			.map({ [weak self](email, passwords) -> Bool in
				if email != nil, email != "",email!.contains("@"), passwords != nil, passwords != "" {
					self?.signInButton.alpha = 1.0
					return true
				}else{
					self?.signInButton.alpha = 0.2
					return false
				}
			})
			.assign(to: \UIButton.isEnabled, on: signInButton)
	}
	
	func createPublisher(publisher : Published<String?>.Publisher)->AnyPublisher<String?,Never>{
		
		let pub = publisher
			.debounce(for: 3, scheduler: DispatchQueue.global(qos: .background))
			.removeDuplicates()
			.eraseToAnyPublisher()
		return pub
	}
	
	//MARK: - Account Creation & Signin Methods
	
	@objc func createNewAccount(){
		
		userAuth = Authentication(email: submittedEmail.lowercased(), password: passwordConfirmation, userName: userName.lowercased())
		do {
			try userAuth.firebaseUserRegistration(isRegistration: true, isError: { [weak self] in
				
				self?.resetUserInput(isRegistration: true)
				
				}, segue: { [weak self](authorizationResult) in
					self?.userAuth.authentication = authorizationResult.credential
					/*
					self?.coreDataAuthModel.coreDataEmail = self?.userAuth.email
					self?.coreDataAuthModel.coreDataPassword = self?.userAuth.password
					self?.coreDataAuthModel.coreDataUserName = self?.userAuth.userName
					self?.coreDataAuthModel.coreDataCredential = self?.userAuth.authentication
					do {
					try self?.context.save()
					}
					catch(let saveError){
					print(saveError.localizedDescription)
					}
					*/
					self?.performSegue(withIdentifier: Keys.Segues.accessSegue, sender: nil)
			})
		}
		catch(let authError){
			print(authError.localizedDescription)
		}
	}
	
	@IBAction func logInButtonTapped(_ sender: Any) {
		
		userAuth = Authentication(email: email.lowercased(), password: password)
		do {
			try userAuth.firebaseUserRegistration(isRegistration: false, isError: { [weak self] in
				
				self?.resetUserInput(isRegistration: false)
				
				}, segue: { [weak self](authResult) in
					
					self?.userAuth.authentication = authResult.credential
					/*
					self?.coreDataAuthModel.coreDataEmail = self?.userAuth.email
					self?.coreDataAuthModel.coreDataPassword = self?.userAuth.password
					self?.coreDataAuthModel.coreDataCredential = self?.userAuth.authentication
					do {
					try self?.context.save()
					}
					catch(let saveError){
					print(saveError.localizedDescription)
					}
					*/
					self?.performSegue(withIdentifier: Keys.Segues.accessSegue, sender: nil)
			})
		}catch(let error){
			print(error.localizedDescription)
		}
	}
	
	func resetUserInput(isRegistration:Bool){
		switch isRegistration {
		case true:
			userNameTextField.text = nil
			createEmailTextField.text = nil
			createPasswordTextField.text = nil
			passwordConfirmationTextField.text = nil
			submitButton.isEnabled = false
			submitButton.alpha = 0.2
			userNameTextField.becomeFirstResponder()
		default:
			emailAddressTextField.text = nil
			passwordTextField.text = nil
			signInButton.isEnabled = false
			signInButton.alpha = 0.2
			emailAddressTextField.becomeFirstResponder()
		}
	}
	
	//MARK: - Navigation
	
	@IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {
	}
}

//MARK: Textfield Observer
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
			submittedEmail = text
		case 4:
			submittedPassword = text
		case 5:
			passwordConfirmation = text
		default:
			break
		}
	}
}






