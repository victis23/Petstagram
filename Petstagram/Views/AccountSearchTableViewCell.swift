//
//  AccountSearchTableViewCell.swift
//  Petstagram
//
//  Created by Scott Leonard on 2/12/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

class AccountSearchTableViewCell: UITableViewCell {
	
	@IBOutlet weak var userName: UILabel!
	@IBOutlet weak var profilePhoto : UIImageView!
	@IBOutlet weak var followButton : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

	@IBAction func followButtonTapped(_ sender: Any) {
	}
}
