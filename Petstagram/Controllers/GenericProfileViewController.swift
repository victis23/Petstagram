//
//  GenericProfileViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/13/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

class GenericProfileViewController: UIViewController {
	
	var account : PetstagramUsers!
	var profileImage : UIImage!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
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
