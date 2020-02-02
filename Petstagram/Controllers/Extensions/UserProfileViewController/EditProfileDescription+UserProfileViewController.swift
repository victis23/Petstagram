//
//  EditProfileDescription+UserProfileViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/31/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

extension UserProfileViewController {
	
	func createEditProfileDescriptionView()-> EditProfileDescription? {
		
		// Creates instance variable for xib file containing view for editing profile.
		let editProfileView = Bundle.main.loadNibNamed("EditProfileView", owner: self, options: nil)
		
		// Downcast from Any to subclass of UIView.
		let editView = editProfileView?.first as? EditProfileDescription
		
		editView?.layer.cornerRadius = 5
		editView?.frame = CGRect(x: 0, y: 0, width: 300, height: 330)
		editView?.center = view.center
		editView?.submitButton.layer.cornerRadius = 5
		
		if let description = editView?.profileDescription {
			
			let color = UIColor(white: 0.9, alpha: 0.2)
			description.text = ""
			description.backgroundColor = color
			description.textColor = .black
			description.layer.cornerRadius = 5
			description.becomeFirstResponder()
		}
		
		return editView
	}
	
	@objc func swipeToDismiss(_ sender: UIPanGestureRecognizer){
		
		let translation = sender.translation(in: self.view)
		guard let movingView = sender.view else {return}
		
		if sender.state == .changed {
		
			movingView.center = CGPoint(x: movingView.center.x + translation.x, y: movingView.center.y + translation.y)
			
			sender.setTranslation(CGPoint(x: 0, y: 0), in: movingView)
		}
		
		if sender.state == .ended {}
		
	}
	
	func editViewAnimations(subView:UIView){
		
		let transformations = CGAffineTransform(translationX: self.view.center.x + 50, y: 0)
			.concatenating(CGAffineTransform(scaleX: 0, y: 0))
		
		subView.transform = transformations
		
		UIView.animate(withDuration: 0.5) {
			subView.transform = .identity
		}
	}
	
	func setDisableSubsciber(){
		isEditProfileSubscriber = isEditingDetails
			.assign(to: \UIButton.isEnabled, on: editProfileInfoButton)
	}
	
	func disableParentView(isDisabled:Bool){
		
		isEditingProfileDetails = isDisabled
		
		isEditingDetails = $isEditingProfileDetails
			.map({ bool -> Bool in
				if bool == true {
					self.editProfileInfoButton.alpha = 0.2
					return false
				}
				self.editProfileInfoButton.alpha = 1.0
				return true
			})
			.eraseToAnyPublisher()
	}
}
