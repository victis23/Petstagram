//
//  GenericProfileViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/13/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

class GenericProfileViewController: UIViewController {
	
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var userName: UILabel!
	@IBOutlet weak var accountImageCollection: UICollectionView!
	@IBOutlet weak var followButton: UIButton!
	@IBOutlet weak var profileDescription: UILabel!
	
	var account : PetstagramUsers!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
		setAccountVisuals()
		getProfileDescription(user: account)
	}
	
	/// Sets description to view using helper class to get data from Google FireStore database.
	func getProfileDescription(user:PetstagramUsers){
		
		let descriptionRetriever = DescriptionRetriever(userID: user.uid)
		
		descriptionRetriever.getDescription { retrievedString in
			
			self.profileDescription.text = retrievedString
		}
	}
	
	func setAccountVisuals(){
		userName.text = account.username
		profileImage.image = account.image
	}
	
	/// Sets attributes for navigation bar.
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		
		if let font = UIFont(name: "Billabong", size: 34) {
			
			self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : font]
		}
		
		self.navigationController?.navigationBar.tintColor = .label
	}
}
