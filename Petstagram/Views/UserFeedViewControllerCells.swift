//
//  UserFeedViewControllerCells.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/23/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

class FeedTableViewCell : UITableViewCell {
	
	@IBOutlet weak var feedImage: UIImageView!
	@IBOutlet weak var accountLabel: UILabel!
	@IBOutlet weak var profileImage: UIImageView!
	
}

class FeedCollectionViewCell : UICollectionViewCell {
	
	@IBOutlet weak var FriendImages: UIImageView!
	@IBOutlet weak var username: UILabel!
}
