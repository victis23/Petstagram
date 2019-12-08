//
//  CreateAccountAppLoginExtension.swift
//  Petstagram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit

extension AppLogin {
	
	func createViewForAccountCreation(){
		
		let dragGesture : UIPanGestureRecognizer = {
			let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(panGesture:)))
			return pan
		}()
		
		view.addSubview(accountCreationUIView)
		addConstraintsToAccountCreationView()
		animateAccountCreationView()
		addSubViewsToAccountCreationView()
		accountCreationUIView.addGestureRecognizer(dragGesture)
	}
	
	func addConstraintsToAccountCreationView(){
		
		NSLayoutConstraint.activate([
			accountCreationUIView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			accountCreationUIView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 812),
			accountCreationUIView.heightAnchor.constraint(equalToConstant: loginArea.frame.height),
			accountCreationUIView.widthAnchor.constraint(equalToConstant: loginArea.frame.width)
		])
	}
	
	func animateAccountCreationView(){
		
		UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.accountCreationUIView.transform = CGAffineTransform(translationX: 0, y: -750)
		}, completion: nil)
	}
	
	@objc func handleGesture(panGesture : UIPanGestureRecognizer){
		
		let translation = panGesture.translation(in: self.view)
		guard let viewToDrag = panGesture.view else {return}
		//		guard let originalCenter = panGesture.view?.center.y else {fatalError()}
		let originalCenter :CGFloat = 1210
		
		if panGesture.state == .changed {
			
			viewToDrag.center = CGPoint(x: viewToDrag.center.x, y: viewToDrag.center.y + translation.y)
			
			if viewToDrag.center.y > originalCenter {
				panGesture.setTranslation(CGPoint(x: 0, y: 0), in: viewToDrag)
			}else{
				viewToDrag.center.y = originalCenter
			}
			
		}
		
		if panGesture.state == .ended {
			if viewToDrag.center.y > 1250 {
				UIView.animate(withDuration: 0.5, animations: {
					self.accountCreationUIView.transform = .identity
				}) { _ in
					self.accountCreationUIView.removeFromSuperview()
				}
			}
		}
	}
	
	func addSubViewsToAccountCreationView(){
		
		let userNameTextField : UITextField = {
			createTextField(with: "Username")
		}()
		let passwordTextField : UITextField = {
			createTextField(with: "Password")
		}()
		let passwordConfirmationTextField : UITextField = {
			createTextField(with: "Password Confirmation")
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
			return button
		}()
		let verticalStack : UIStackView = {
			let stack = UIStackView()
			stack.axis = .vertical
			stack.translatesAutoresizingMaskIntoConstraints = false
			stack.spacing = 31
			stack.alignment = .center
			return stack
		}()
		let dragIndicator : UIView = {
			let view = UIView()
			view.backgroundColor = .systemGray
			view.layer.cornerRadius = 2.5
			view.alpha = 0.5
			view.translatesAutoresizingMaskIntoConstraints = false
			return view
		}()
		
		accountCreationUIView.addSubview(dragIndicator)
		accountCreationUIView.addSubview(verticalStack)
		[userNameTextField,passwordTextField,passwordConfirmationTextField,submitButton].forEach {
			
			verticalStack.addArrangedSubview($0)
		}
		
		NSLayoutConstraint.activate([
			verticalStack.centerYAnchor.constraint(equalTo: accountCreationUIView.centerYAnchor),
			verticalStack.centerXAnchor.constraint(equalTo: accountCreationUIView.centerXAnchor),
			dragIndicator.topAnchor.constraint(equalTo: accountCreationUIView.topAnchor, constant: 10),
			dragIndicator.widthAnchor.constraint(equalToConstant: 100),
			dragIndicator.heightAnchor.constraint(equalToConstant: 5),
			dragIndicator.centerXAnchor.constraint(equalTo: accountCreationUIView.centerXAnchor),
			userNameTextField.heightAnchor.constraint(equalToConstant: 50),
			userNameTextField.widthAnchor.constraint(equalToConstant: 284),
			passwordTextField.heightAnchor.constraint(equalToConstant: 50),
			passwordTextField.widthAnchor.constraint(equalToConstant: 284),
			passwordConfirmationTextField.heightAnchor.constraint(equalToConstant: 50),
			passwordConfirmationTextField.widthAnchor.constraint(equalToConstant: 284),
			submitButton.heightAnchor.constraint(equalToConstant: 50),
			submitButton.widthAnchor.constraint(equalToConstant: 264),
		])
	}
	
	func createTextField(with placeholder :String)->UITextField{
		
		let textfield = UITextField()
		textfield.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.03)
		textfield.layer.borderColor = UIColor.tertiaryLabel.cgColor
		textfield.layer.borderWidth = 0.5
		textfield.layer.cornerRadius = 5
		textfield.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22),
			NSAttributedString.Key.foregroundColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.1),
		])
		textfield.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 10)
		textfield.translatesAutoresizingMaskIntoConstraints = false
		return textfield
	}
}
