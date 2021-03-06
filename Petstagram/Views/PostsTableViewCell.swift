//
//  SelectedImageTableViewCell.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/18/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

/// Cell in tableview controlled by AccountImageListTableViewController.
class PostsTableViewCell : UITableViewCell {
	
	@IBOutlet weak var profilePhoto: UIImageView!
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var username: UILabel!
	@IBOutlet weak var postDate: UILabel!
}
