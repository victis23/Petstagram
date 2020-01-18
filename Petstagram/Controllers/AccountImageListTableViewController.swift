//
//  AccountImageListTableViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/18/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

class AccountImageListTableViewController: UITableViewController {
	
	enum sections {
		case images
		case comments
	}
	
	// Stored Property that gets its initial value during segue.
	var profileImages : [AccountImages] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
