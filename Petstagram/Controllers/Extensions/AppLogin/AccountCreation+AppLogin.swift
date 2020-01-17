//
//  CreateAccountAppLoginExtension.swift
//  Petstagram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit
import Combine

/// Extension of AppLogin that contains methods that handle creation of new accounts.
extension AppLogin {
	
	///Creates view that contains views needed for creating a new user account.
	/// - Important: `dragGesture` enables dragging of entire view.
	func createViewForAccountCreation(){
		
		let dragGesture : UIPanGestureRecognizer = {
			let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(panGesture:)))
			return pan
		}()
		
		view.addSubview(accountCreationUIView)
		addConstraintsToAccountCreationView()
		animateAccountCreationView()
		addSubViewsToAccountCreationView()
		// Adds our gesture object to the view.
		accountCreationUIView.addGestureRecognizer(dragGesture)
	}
	
	/// Adds needed constraints to view.
	func addConstraintsToAccountCreationView(){
		
		NSLayoutConstraint.activate([
			accountCreationUIView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			accountCreationUIView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 896),
			accountCreationUIView.heightAnchor.constraint(equalToConstant: loginArea.frame.height),
			accountCreationUIView.widthAnchor.constraint(equalToConstant: loginArea.frame.width)
		])
	}
	
	/// Controls animation that brings view onto screen when user clicks button `create an account` which triggers  `userRequestsNewAccountCreationButtonTapped(sender:)`
	func animateAccountCreationView(){
		
		UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.accountCreationUIView.transform = CGAffineTransform(translationX: 0, y: self.deviceSizeChecker().raisedValue)
		}, completion: nil)
	}
	
	
	/// Limits the height to which the account creation view can rise on the screen.
	/// - Returns: A Tuple Containing
	/// 	- `raisedValue`: The value to which the view has moved
	/// 	- `dragLimit`: The maximum height the view can rise.
	func deviceSizeChecker() -> (raisedValue:CGFloat,dragLimit:CGFloat){
		var raisedValue = CGFloat()
		var limitPercentage = CGFloat()
		
		if view.frame.height > 812 {
			// iPhone 11 Pro Max Screen Size.
			raisedValue = 800 * -1
			limitPercentage = 1.499
		}else{
			// Standard Iphone Screen Size.
			raisedValue = 834 * -1
			limitPercentage = 1.599
		}
		return (raisedValue,limitPercentage)
	}
	
	/// Handles user interaction with view.
	/// - Note: This method uses the Tuple value set in `deviceSizeChecker()` to determine where to stop the view.
	@objc func handleGesture(panGesture : UIPanGestureRecognizer){
		
		let translation = panGesture.translation(in: self.view)
		guard let viewToDrag = panGesture.view else {return}
		
		let originalCenter :CGFloat = view.frame.height * deviceSizeChecker().dragLimit
		
		// Happens while user is interacting with view.
		if panGesture.state == .changed {
			
			viewToDrag.center = CGPoint(x: viewToDrag.center.x, y: viewToDrag.center.y + translation.y)
			
			// If view is pushed above limit (negative value because we're moving upwards from center) established by original center it's returned to its initial position (not moved) thus view is unable to cross this barrier.
			if viewToDrag.center.y > originalCenter {
				panGesture.setTranslation(CGPoint(x: 0, y: 0), in: viewToDrag)
			}else{
				viewToDrag.center.y = originalCenter
			}
			
		}
		
		// Happens when user stops interacting with view. This method control flow statement controls when the view is returned to original position and dismissed from screen.
		if panGesture.state == .ended {
			if viewToDrag.center.y > originalCenter + 50 {
				UIView.animate(withDuration: 0.5, animations: {
					self.accountCreationUIView.transform = .identity
				}) { _ in
					self.accountCreationUIView.removeFromSuperview()
				}
			}
		}
	}
	
	/// Adds visible indicators to view such as a box that indicates to user that view can be dragged. Adds textfield to a stack vertical stack view.
	/// - Note: `verticalStack` - Holds UI elements.
	func addSubViewsToAccountCreationView(){
		
		let verticalStack : UIStackView = {
			let stack = UIStackView()
			stack.axis = .vertical
			stack.translatesAutoresizingMaskIntoConstraints = false
			stack.spacing = 31
			stack.alignment = .center
			return stack
		}()
		
		// Just a rounded-corner rectangle to show users view can be dragged.
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
	
		//Array of UIView Elements being added into a vertical stack.
		[userNameTextField,createEmailTextField,createPasswordTextField,passwordConfirmationTextField,submitButton].forEach {
			
			verticalStack.addArrangedSubview($0)
		}
		
		NSLayoutConstraint.activate([
			verticalStack.centerYAnchor.constraint(equalTo: accountCreationUIView.centerYAnchor),
			verticalStack.centerXAnchor.constraint(equalTo: accountCreationUIView.centerXAnchor),
			dragIndicator.topAnchor.constraint(equalTo: accountCreationUIView.topAnchor, constant: 10),
			dragIndicator.widthAnchor.constraint(equalToConstant: 100),
			dragIndicator.heightAnchor.constraint(equalToConstant: 5),
			dragIndicator.centerXAnchor.constraint(equalTo: accountCreationUIView.centerXAnchor),
			createEmailTextField.heightAnchor.constraint(equalToConstant: 50),
			createEmailTextField.widthAnchor.constraint(equalToConstant: 284),
			userNameTextField.heightAnchor.constraint(equalToConstant: 50),
			userNameTextField.widthAnchor.constraint(equalToConstant: 284),
			createPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
			createPasswordTextField.widthAnchor.constraint(equalToConstant: 284),
			passwordConfirmationTextField.heightAnchor.constraint(equalToConstant: 50),
			passwordConfirmationTextField.widthAnchor.constraint(equalToConstant: 284),
			submitButton.heightAnchor.constraint(equalToConstant: 50),
			submitButton.widthAnchor.constraint(equalToConstant: 264),
		])
	}
}
