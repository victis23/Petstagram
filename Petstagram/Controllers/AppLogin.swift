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
	
	var userNameSubscriber : AnyCancellable!
	var passwordSubscriber : AnyCancellable!
	@Published var userName : String!
	@Published var password : String!
	@Published var passwordConfirmation : String!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setLoginArea()
	}
	
	@IBAction func logInButtonTapped(_ sender: Any) {
		
		performSegue(withIdentifier: Keys.Segues.accessSegue, sender: nil)
	}
	
	@IBAction func createAnAccount(_ sender: Any) {
		
		createViewForAccountCreation()
	}
	
}
	





