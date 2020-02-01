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
		editView?.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
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
		
	}
}
