//
//  UserFeedViewController.swift
//  fakerGram
//
//  Created by Scott Leonard on 12/6/19.
//  Copyright © 2019 DuhMarket. All rights reserved.
//

import UIKit

class UserFeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		setupNavigation()
    }
	
	func setupNavigation(){
		self.title = "Petstagram"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Billabong", size: 35)!]
	}

}
