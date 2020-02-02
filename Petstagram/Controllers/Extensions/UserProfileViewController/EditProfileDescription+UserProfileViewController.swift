//
//  EditProfileDescription+UserProfileViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/31/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit
import Combine

extension UserProfileViewController : UITextViewDelegate {
	
	func createEditProfileDescriptionView()-> EditProfileDescription? {
		
		// Creates instance variable for xib file containing view for editing profile.
		let editProfileView = Bundle.main.loadNibNamed("EditProfileView", owner: self, options: nil)
		
		// Downcast from Any to subclass of UIView.
		let editView = editProfileView?.first as? EditProfileDescription
		
		editView?.layer.cornerRadius = 5
		editView?.frame = CGRect(x: 0, y: 0, width: 300, height: 330)
		editView?.center = view.center
		editView?.submitButton.layer.cornerRadius = 5
		editView?.layer.shadowOffset = CGSize(width: 5, height: 5)
		editView?.layer.shadowOpacity = 0.3
		editView?.layer.shadowRadius = 10
		
		
		if let description = editView?.profileDescription {
			
			let color = UIColor(white: 0.9, alpha: 0.2)
			description.text = "\(aboutThePetLabel.text ?? "") \(aboutTheOwnerLabel.text ?? "")"
			description.backgroundColor = color
			description.textColor = .black
			description.layer.cornerRadius = 5
			description.becomeFirstResponder()
			description.delegate = self
			
			let count = description.text.count
			editView?.textCount.text = "\(count)/200"
		}
		
		return editView
	}
	
	/// Updates count label for user input.
	/// - Important: profileDescriptionViewObject references `editView's` textview in memory.
	func textViewDidChange(_ textView: UITextView) {
		
		let count = textView.text.count
		
		if let countLabel = profileDescriptionViewObject.textCount {
			
			if count >= 189 {
				countLabel.textColor = .orange
			}
			
			if count >= 200 {
				countLabel.textColor = .red
			}
			
			countLabel.text = "\(textView.text.count)/200"
			
		}
		 
		
		 
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
}
