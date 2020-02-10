//
//  SearchControllerViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/7/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit

class SearchControllerViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
		// Do any additional setup after loading the view.
	}
	
	func setNavigationBar(){
		self.navigationItem.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 34)!]
		self.navigationController?.navigationBar.tintColor = .label
	}
	
}
