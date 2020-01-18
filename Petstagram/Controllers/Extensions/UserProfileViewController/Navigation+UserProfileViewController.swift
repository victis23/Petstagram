//
//  Navigation+UserProfileViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/18/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

/// Handles Segues
extension UserProfileViewController {
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue .identifier == Keys.Segues.imageViewer {
			
			guard let destinationController = segue.destination as? AccountImageListTableViewController else {return}
			
			destinationController.profileImages = images
		}
	}
}
