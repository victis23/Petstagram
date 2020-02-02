//
//  EditProfileDescription.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/31/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

class EditProfileDescription: UIView {

	@IBOutlet weak var label: UILabel!
	
	@IBOutlet weak var submitButton: UIButton!
	
	@IBOutlet weak var profileDescription: UITextView!
	
	@IBAction func tapSubmitButton(_ sender: UIButton) {
		
		let vc = parentContainerViewController() as! UserProfileViewController
		vc.aboutTheOwnerLabel.text = profileDescription.text
//		vc.isEditingProfileDetails = false
		self.removeFromSuperview()
	}
}
