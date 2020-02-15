//
//  DisableBackgroundView.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/15/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit
import Combine


/// Sets Publisher and Subscriber that controls when the parent view is disabled.
extension UserProfileViewController {
	
	/// Method sets subscribers for view.
	/// - NOTE: Controls whether user can interact with collectionview and edit profile button while profile editing dialog box is presented.
	func setDisableSubsciber(){
		
		isEditProfileSubscriber = isEditingDetails
			.assign(to: \UIButton.isEnabled, on: editProfileInfoButton)
		
		isEditProfileSubscriber = isEditingDetails
			.assign(to: \UICollectionView.isUserInteractionEnabled, on: accountImages)
	}
	
	/// Sets value recieved by publisher when user taps on the edit profile button.
	/// - Note: Changes opacity of Edit Button and CollectionView.
	func disableParentView(isDisabled:Bool){
		
		let views :[UIView] = [editProfileInfoButton,accountImages,aboutThePetLabel]
		
		isEditingProfileDetails = isDisabled
		
		isEditingDetails = $isEditingProfileDetails
			.map({ bool -> Bool in
				// You are IN Edit mode. View Enabled = False
				if bool == true {
					self.changeViewOpacity(with: views, alphaIsNotLowered: bool)
					return false
				}
				// Default: You are NOT in edit mode. View Enabled = True
				self.changeViewOpacity(with: views, alphaIsNotLowered: bool)
				return true
			})
			.eraseToAnyPublisher()
	}
	
	func changeViewOpacity(with uiViews : [UIView], alphaIsNotLowered:Bool){
		
		var alpha : CGFloat = 1.0
		
		// The view opacity is not lowered.
		if alphaIsNotLowered {
			alpha = 0.2
		}
		
		uiViews.forEach { view in
			view.alpha = alpha
		}
	}
}
