//
//  AccountImageListTableViewController.swift
//  Petstagram
//
//  Created by Scott Leonard on 1/18/20.
//  Copyright © 2020 DuhMarket. All rights reserved.
//

import UIKit

class PostsTableViewController: UITableViewController {
	
	/// Enum that determines sections in source of truth
	private enum Sections {
		case images
		case comments
	}
	/*
	/// Manages user comments for images.
	struct Comments : Hashable, Equatable {
		var comment : [String]?
		var accountImage : AccountImages
		var id : String {
			return accountImage.id
		}
		
		init(accountImage : AccountImages) {
			self.accountImage = accountImage
		}
		
		func hash(into hasher : inout Hasher){
			hasher.combine(id)
		}
		
		static func == (lhs: Comments, rhs: Comments)->Bool{
			lhs.id == rhs.id
		}
	}
	*/
	
	// Stored Property that gets its initial value during segue.
	var profileImages : [AccountImages] = []

	// Indicates which image triggered segue if isUserFeed == true.
	var imagePointer : String?
	
	// Image displayed in profile image icon.
	var profileImage : UIImage?
	
	// source of truth instance.
	private var datasource : UITableViewDiffableDataSource<Sections,AccountImages>!

    override func viewDidLoad() {
		
        super.viewDidLoad()
		setNavigationControls()
		createDataSource()
		createSnapshot(accountImages: profileImages)
		determineTableViewPosition()
    }
	
	func setNavigationControls(){
		navigationController?.navigationItem.backBarButtonItem?.title = " "
	}
	
	/// Determines where the tableview should focus based off of the image that triggered the segue.
	func determineTableViewPosition(){
		
		guard let imagePointer = imagePointer else {return}
		
		guard let item = profileImages.first(where: { (item) -> Bool in
			item.id == imagePointer
		}) else {return}
		
		if let indexPath = datasource.indexPath(for: item) {
			
			tableView.scrollToRow(at: indexPath, at: .top, animated: true)
		}
	}
	
	/// Utilizes snapshot data to display visual representation to user in a tableview.
	func createDataSource(){
		datasource = UITableViewDiffableDataSource<Sections,AccountImages>(tableView: tableView, cellProvider: { (tableView, indexPath, accountImages) -> UITableViewCell? in
			
			guard let imageCell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as? PostsTableViewCell else {return UITableViewCell()}
			
			imageCell.profileImageView.image = accountImages.image
			imageCell.profileImageView.contentMode = .scaleAspectFill
			imageCell.profilePhoto.image = self.profileImage
			imageCell.profilePhoto.contentMode = .scaleAspectFill
			
			let widthOfProfilePhoto = imageCell.profilePhoto.frame.width
			
			imageCell.profilePhoto.layer.cornerRadius = widthOfProfilePhoto / 2
			
			return imageCell
			
		})
	}
	
	/// Source of truth for tableview.
	func createSnapshot(accountImages : [AccountImages]){
		
		var snapshot = NSDiffableDataSourceSnapshot<Sections,AccountImages>()
		snapshot.appendSections([.images])
		snapshot.appendItems(accountImages, toSection: .images)
		
		datasource.apply(snapshot, animatingDifferences: true, completion: {})
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 450
	}
}
